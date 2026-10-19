const db = require('../../config/database');

class DashboardService {
  async getDashboardStats() {
    // Pharmacy Metrics
    const totalMedicinesRes = await db.query('SELECT COUNT(*) as count FROM medicines');
    const totalMedicines = totalMedicinesRes[0]?.count || 0;

    const totalClassificationsRes = await db.query('SELECT COUNT(*) as count FROM medicine_classifications WHERE is_active = 1');
    const activeClassifications = totalClassificationsRes[0]?.count || 0;

    const lowStockRes = await db.query('SELECT COUNT(*) as count FROM medicines WHERE stock_quantity <= reorder_level AND stock_quantity > 0');
    const lowStockItems = lowStockRes[0]?.count || 0;

    const outOfStockRes = await db.query('SELECT COUNT(*) as count FROM medicines WHERE stock_quantity = 0');
    const outOfStockItems = outOfStockRes[0]?.count || 0;

    const totalInventoryValueRes = await db.query('SELECT SUM(price * stock_quantity) as total FROM medicines');
    const totalInventoryValue = totalInventoryValueRes[0]?.total || 0;

    // Supplier & Purchase Metrics
    const totalSuppliersRes = await db.query('SELECT COUNT(*) as count FROM medicine_suppliers WHERE is_active = 1');
    const totalSuppliers = totalSuppliersRes[0]?.count || 0;

    const purchasesSummaryRes = await db.query('SELECT COUNT(*) as count, SUM(total_amount) as total FROM purchases');
    const totalPurchases = purchasesSummaryRes[0]?.count || 0;
    const totalPurchaseAmount = purchasesSummaryRes[0]?.total || 0;

    // Clinical Metrics
    const totalPatientsRes = await db.query('SELECT COUNT(*) as count FROM patients');
    const totalPatients = totalPatientsRes[0]?.count || 0;

    const opdCountRes = await db.query("SELECT COUNT(*) as count FROM patients WHERE UPPER(patient_type) = 'OPD'");
    const totalOpdPatients = opdCountRes[0]?.count || 0;

    const indoorCountRes = await db.query("SELECT COUNT(*) as count FROM patients WHERE UPPER(patient_type) = 'INDOOR'");
    const totalIndoorPatients = indoorCountRes[0]?.count || 0;

    const ayuCountRes = await db.query("SELECT COUNT(*) as count FROM patients WHERE department LIKE '%Ayur%'");
    const ayurvedicPatients = ayuCountRes[0]?.count || 0;

    const physioCountRes = await db.query("SELECT COUNT(*) as count FROM patients WHERE department LIKE '%Physio%'");
    const physioPatients = physioCountRes[0]?.count || 0;

    const todayStr = new Date().toISOString().split('T')[0];
    const todayApptRes = await db.query('SELECT COUNT(*) as count FROM appointments WHERE appointment_date = $1', [todayStr]);
    const todayAppointments = todayApptRes[0]?.count || 0;

    // Active OPD List for Dashboard
    const opdList = await db.query(
      `SELECT * FROM patients 
       WHERE UPPER(patient_type) = 'OPD' 
       ORDER BY id DESC LIMIT 10`
    );

    // Active Indoor Patient List for Dashboard
    const indoorList = await db.query(
      `SELECT * FROM patients 
       WHERE UPPER(patient_type) = 'INDOOR' 
       ORDER BY id DESC LIMIT 10`
    );

    // Patient Directory List for Dashboard
    const patientList = await db.query(
      'SELECT * FROM patients ORDER BY id DESC LIMIT 10'
    );

    // Today / Upcoming Appointment List for Dashboard
    const appointmentList = await db.query(
      'SELECT * FROM appointments ORDER BY appointment_date DESC, token_number ASC LIMIT 10'
    );

    // Distribution by classification
    const distributionSql = `
      SELECT c.name as classification, COUNT(m.id) as item_count, SUM(m.stock_quantity) as total_stock
      FROM medicine_classifications c
      LEFT JOIN medicines m ON m.classification_id = c.id
      GROUP BY c.id, c.name
      ORDER BY item_count DESC
    `;
    const classificationDistribution = await db.query(distributionSql);

    // Stock alert items
    const alertItemsSql = `
      SELECT m.id, m.name, m.sku_code, m.stock_quantity, m.reorder_level, c.name as classification_name
      FROM medicines m
      LEFT JOIN medicine_classifications c ON m.classification_id = c.id
      WHERE m.stock_quantity <= m.reorder_level
      ORDER BY m.stock_quantity ASC
      LIMIT 10
    `;
    const stockAlerts = await db.query(alertItemsSql);

    // Recent Activity Logs
    const recentLogs = await db.query('SELECT * FROM activity_logs ORDER BY id DESC LIMIT 10');

    return {
      kpi: {
        totalMedicines,
        activeClassifications,
        lowStockItems,
        outOfStockItems,
        totalInventoryValue: parseFloat(totalInventoryValue.toFixed(2)),
        totalSuppliers,
        totalPurchases,
        totalPurchaseAmount: parseFloat(totalPurchaseAmount.toFixed(2)),
        totalPatients,
        totalOpdPatients,
        totalIndoorPatients,
        ayurvedicPatients,
        physioPatients,
        todayAppointments
      },
      classificationDistribution,
      stockAlerts,
      recentLogs,
      opdList,
      indoorList,
      patientList,
      appointmentList
    };
  }
}

module.exports = new DashboardService();
