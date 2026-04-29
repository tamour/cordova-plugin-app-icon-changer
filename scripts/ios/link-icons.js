const fs = require('fs');
const path = require('path');
const xcode = require('xcode');

module.exports = function(context) {
    const projectRoot = context.opts.projectRoot;
    const platformRoot = path.join(projectRoot, 'platforms/ios');
    const projectPath = path.join(platformRoot, 'Icon Switcher - Demo.xcodeproj/project.pbxproj');
    
    if (!fs.existsSync(projectPath)) return;

    const proj = xcode.project(projectPath);
    proj.parseSync();

    // List the 9 files exactly as they appear in your ZIP
    const icons = [
        'icon-switcher1-60.png', 'icon-switcher1-60@2x.png', 'icon-switcher1-60@3x.png',
        'icon-switcher2-60.png', 'icon-switcher2-60@2x.png', 'icon-switcher2-60@3x.png',
        'icon-switcher3-60.png', 'icon-switcher3-60@2x.png', 'icon-switcher3-60@3x.png'
    ];

    const groupKey = proj.findPBXGroupKey({ name: 'Resources' });

    icons.forEach(icon => {
        // Add the file to the project resources without requiring it to be in the plugin folder
        proj.addResourceFile(icon, {}, groupKey);
    });

    fs.writeFileSync(projectPath, proj.writeSync());
    console.log('Successfully linked alternate icons to Xcode project.');
};