const db = require('../../config/database');

class PurchaseService {
  async getAllPurchases(search = '', supplierId = '') {
    let sql = `
      SELECT p.*, s.name as supplier_name, s.code as supplier_code,
             (SELECT COUNT(*) FROM purchase_items pi WHERE pi.purchase_id = p.id) as item_count
      FROM purchases p
      JOIN medicine_suppliers s ON p.supplier_id = s.id
      WHERE 1=1
    `;
    const params = [];
    let paramIndex = 1;

    if (search) {
      sql += ` AND (p.invoice_no LIKE $${paramIndex} OR s.name LIKE $${paramIndex} OR p.payment_mode LIKE $${paramIndex})`;
      params.push(`%${search}%`);
      paramIndex++;
    }

    if (supplierId) {
      sql += ` AND p.supplier_id = $${paramIndex}`;
      params.push(supplierId);
      paramIndex++;
    }

    sql += ' ORDER BY p.id DESC';
    return await db.query(sql, params);
  }

  async getPurchaseById(id) {
    const headerRows = await db.query(
      `SELECT p.*, s.name as supplier_name, s.code as supplier_code, s.phone as supplier_phone, s.email as supplier_email, s.gstin as supplier_gstin
       FROM purchases p
       JOIN medicine_suppliers s ON p.supplier_id = s.id
       WHERE p.id = $1`,
      [id]
    );

    if (headerRows.length === 0) return null;
    const purchase = headerRows[0];

    const items = await db.query(
      `SELECT pi.*, m.name as medicine_name, m.sku_code, m.unit
       FROM purchase_items pi
       JOIN medicines m ON pi.medicine_id = m.id
       WHERE pi.purchase_id = $1`,
      [id]
    );

    purchase.items = items;
    return purchase;
  }

  async createPurchase(data) {
    const {
      invoice_no,
      supplier_id,
      purchase_date,
      payment_status = 'Paid',
      payment_mode = 'Bank Transfer',
      tax_amount = 0,
      discount_amount = 0,
      notes = '',
      items = []
    } = data;

    if (!supplier_id) {
      throw new Error('Supplier ID is required.');
    }
    if (!items || items.length === 0) {
      throw new Error('Purchase must contain at least one medicine item.');
    }

    let finalInvoiceNo = invoice_no ? invoice_no.trim() : '';
    if (!finalInvoiceNo) {
      const countRes = await db.query('SELECT COUNT(*) as count FROM purchases');
      const nextNum = (countRes[0]?.count || 0) + 1;
      const year = new Date().getFullYear();
      finalInvoiceNo = `PUR-${year}-${String(nextNum).padStart(4, '0')}`;
    }

    // Calculate subtotal from items
    let subtotal = 0;
    const processedItems = items.map(item => {
      const qty = parseInt(item.quantity, 10) || 0;
      const price = parseFloat(item.unit_price) || 0;
      const total = qty * price;
      subtotal += total;
      return {
        medicine_id: item.medicine_id,
        quantity: qty,
        unit_price: price,
        batch_no: item.batch_no || '',
        expiry_date: item.expiry_date || '',
        total_price: total
      };
    });

    const tax = parseFloat(tax_amount) || 0;
    const discount = parseFloat(discount_amount) || 0;
    const totalAmount = subtotal + tax - discount;

    const purDate = purchase_date || new Date().toISOString().split('T')[0];

    // Insert purchase header
    const insertHeaderSql = `
      INSERT INTO purchases (invoice_no, supplier_id, purchase_date, payment_status, payment_mode, subtotal, tax_amount, discount_amount, total_amount, notes)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
    `;
    const res = await db.query(insertHeaderSql, [
      finalInvoiceNo,
      supplier_id,
      purDate,
      payment_status,
      payment_mode,
      subtotal,
      tax,
      discount,
      totalAmount,
      notes
    ]);

    const purchaseId = res[0]?.id;

    // Insert items & update medicine stock
    for (const it of processedItems) {
      await db.query(
        `INSERT INTO purchase_items (purchase_id, medicine_id, quantity, unit_price, batch_no, expiry_date, total_price)
         VALUES ($1, $2, $3, $4, $5, $6, $7)`,
        [purchaseId, it.medicine_id, it.quantity, it.unit_price, it.batch_no, it.expiry_date, it.total_price]
      );

      // Increment stock in medicines table
      await db.query(
        `UPDATE medicines 
         SET stock_quantity = stock_quantity + $1, updated_at = CURRENT_TIMESTAMP
         WHERE id = $2`,
        [it.quantity, it.medicine_id]
      );
    }

    await db.query(
      `INSERT INTO activity_logs (action, details) VALUES ($1, $2)`,
      ['CREATE_PURCHASE', `Recorded purchase bill ${finalInvoiceNo} (Total: ₹${totalAmount.toFixed(2)}) and updated medicine inventory.`]
    );

    return await this.getPurchaseById(purchaseId);
  }

  async deletePurchase(id) {
    const existing = await this.getPurchaseById(id);
    if (!existing) {
      throw new Error('Purchase invoice not found.');
    }

    // Revert inventory stocks for each item
    if (existing.items && existing.items.length > 0) {
      for (const it of existing.items) {
        await db.query(
          `UPDATE medicines 
           SET stock_quantity = MAX(0, stock_quantity - $1), updated_at = CURRENT_TIMESTAMP
           WHERE id = $2`,
          [it.quantity, it.medicine_id]
        );
      }
    }

    await db.query('DELETE FROM purchase_items WHERE purchase_id = $1', [id]);
    await db.query('DELETE FROM purchases WHERE id = $1', [id]);

    await db.query(
      `INSERT INTO activity_logs (action, details) VALUES ($1, $2)`,
      ['DELETE_PURCHASE', `Deleted purchase invoice: ${existing.invoice_no}`]
    );

    return true;
  }
}

module.exports = new PurchaseService();
