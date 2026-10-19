const { Pool } = require('pg');
const sqlite3 = require('sqlite3').verbose();
const path = require('path');
const fs = require('fs');

let dbDriver = 'sqlite'; // 'postgres' or 'sqlite'
let pgPool = null;
let sqliteDb = null;

// Initialize database
async function initDatabase() {
  const connectionString = process.env.DATABASE_URL || 'postgresql://postgres:postgres@localhost:5432/hms_db';
  const usePostgres = process.env.USE_POSTGRES === 'true';

  if (usePostgres) {
    try {
      pgPool = new Pool({ connectionString });
      await pgPool.query('SELECT NOW()');
      dbDriver = 'postgres';
      console.log(' Connected to PostgreSQL database');
      return;
    } catch (err) {
      console.warn('⚠️  PostgreSQL connection failed, falling back to SQLite engine:', err.message);
    }
  }

  // Fallback / default SQLite engine
  const dbDir = path.join(__dirname, '../../data');
  if (!fs.existsSync(dbDir)) {
    fs.mkdirSync(dbDir, { recursive: true });
  }

  const dbPath = path.join(dbDir, 'hms.db');
  dbDriver = 'sqlite';
  
  return new Promise((resolve, reject) => {
    sqliteDb = new sqlite3.Database(dbPath, (err) => {
      if (err) {
        console.error('❌ Failed to initialize SQLite database:', err);
        return reject(err);
      }
      console.log(` Connected to database engine (SQLite: ${dbPath})`);
      resolve();
    });
  });
}

// Universal query runner supporting both PG ($1, $2) and SQLite (?, ?)
async function query(text, params = []) {
  if (dbDriver === 'postgres') {
    const result = await pgPool.query(text, params);
    return result.rows;
  }

  // SQLite syntax conversion: replace $1, $2 with ?
  let sqliteSql = text;
  sqliteSql = sqliteSql.replace(/\$(\d+)/g, '?');

  return new Promise((resolve, reject) => {
    // Determine query type
    const trimmed = sqliteSql.trim().toUpperCase();
    if (trimmed.startsWith('SELECT') || trimmed.startsWith('PRAGMA') || trimmed.includes('RETURNING')) {
      // Remove RETURNING * clause for SQLite if present and run
      let execSql = sqliteSql.replace(/RETURNING\s+\*/i, '').trim();
      sqliteDb.all(execSql, params, (err, rows) => {
        if (err) return reject(err);
        resolve(rows || []);
      });
    } else {
      sqliteDb.run(sqliteSql, params, function (err) {
        if (err) return reject(err);
        resolve([{ id: this.lastID, changes: this.changes }]);
      });
    }
  });
}

function getDriver() {
  return dbDriver;
}

module.exports = {
  initDatabase,
  query,
  getDriver
};
