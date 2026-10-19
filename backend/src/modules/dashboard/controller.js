const dashboardService = require('./service');

class DashboardController {
  async getStats(req, res) {
    try {
      const stats = await dashboardService.getDashboardStats();
      res.json({ success: true, data: stats });
    } catch (err) {
      res.status(500).json({ success: false, error: err.message });
    }
  }
}

module.exports = new DashboardController();
