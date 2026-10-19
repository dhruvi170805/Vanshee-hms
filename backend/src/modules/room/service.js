const db = require('../../config/database');

async function getAllRooms(search = '', status = '') {
  let query = 'SELECT * FROM rooms WHERE 1=1';
  const params = [];

  if (search) {
    params.push(`%${search}%`);
    query += ` AND (room_number LIKE $${params.length} OR ward_name LIKE $${params.length} OR room_type LIKE $${params.length})`;
  }

  if (status && status !== 'all') {
    params.push(status);
    query += ` AND status = $${params.length}`;
  }

  query += ' ORDER BY floor_number ASC, room_number ASC';
  return await db.query(query, params);
}

async function getRoomById(id) {
  const rows = await db.query('SELECT * FROM rooms WHERE id = $1', [id]);
  return rows[0] || null;
}

async function createRoom(data) {
  const { room_number, ward_name, room_type, total_beds, occupied_beds, floor_number, daily_charge, status } = data;
  if (!room_number || !ward_name) throw new Error('Room Number and Ward Name are required');

  const existing = await db.query('SELECT id FROM rooms WHERE room_number = $1', [room_number]);
  if (existing.length > 0) throw new Error(`Room "${room_number}" already exists`);

  const res = await db.query(
    `INSERT INTO rooms (room_number, ward_name, room_type, total_beds, occupied_beds, floor_number, daily_charge, status)
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
    [
      room_number,
      ward_name,
      room_type || 'General',
      total_beds || 1,
      occupied_beds || 0,
      floor_number || 1,
      daily_charge || 0,
      status || 'Available'
    ]
  );
  return await getRoomById(res[0]?.id);
}

async function updateRoom(id, data) {
  const existing = await getRoomById(id);
  if (!existing) throw new Error('Room not found');

  const { room_number, ward_name, room_type, total_beds, occupied_beds, floor_number, daily_charge, status } = data;

  await db.query(
    `UPDATE rooms
     SET room_number = $1, ward_name = $2, room_type = $3, total_beds = $4,
         occupied_beds = $5, floor_number = $6, daily_charge = $7, status = $8,
         updated_at = CURRENT_TIMESTAMP
     WHERE id = $9`,
    [
      room_number !== undefined ? room_number : existing.room_number,
      ward_name !== undefined ? ward_name : existing.ward_name,
      room_type !== undefined ? room_type : existing.room_type,
      total_beds !== undefined ? total_beds : existing.total_beds,
      occupied_beds !== undefined ? occupied_beds : existing.occupied_beds,
      floor_number !== undefined ? floor_number : existing.floor_number,
      daily_charge !== undefined ? daily_charge : existing.daily_charge,
      status !== undefined ? status : existing.status,
      id
    ]
  );
  return await getRoomById(id);
}

async function deleteRoom(id) {
  const existing = await getRoomById(id);
  if (!existing) throw new Error('Room not found');

  await db.query('DELETE FROM rooms WHERE id = $1', [id]);
  return true;
}

module.exports = {
  getAllRooms,
  getRoomById,
  createRoom,
  updateRoom,
  deleteRoom
};
