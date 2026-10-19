const fs = require('fs');
const path = require('path');

function registerModules(app, apiPrefix = '/api/v1') {
  const modulesDir = __dirname;

  console.log('⚡ Auto-loading API Feature Modules...');

  const items = fs.readdirSync(modulesDir, { withFileTypes: true });

  items.forEach(item => {
    if (item.isDirectory()) {
      const moduleName = item.name;
      const routesPath = path.join(modulesDir, moduleName, 'routes.js');

      if (fs.existsSync(routesPath)) {
        const router = require(routesPath);
        const routePath = `${apiPrefix}/${moduleName}`;
        app.use(routePath, router);
        console.log(` Mounted module [${moduleName.toUpperCase()}] -> ${routePath}`);
      }
    }
  });
}

module.exports = { registerModules };
