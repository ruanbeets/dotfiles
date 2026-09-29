// One-shot native Plasma configuration, not an installed KWin script or daemon.
// Only refine an existing TOP panel containing KVitals; never create a layout.
var candidates = panels().filter(function(p) {
    return p.location === 'top' && p.widgets('org.kde.plasma.kvitals').length === 1;
});
if (candidates.length !== 1) {
    print('Panel left unchanged: expected one top panel with KVitals. See kde/README.md.');
} else {
    var panel = candidates[0];
    var vitals = panel.widgets('org.kde.plasma.kvitals')[0];
    vitals.currentConfigGroup = ['General'];
    // Keep the current GPU identifiers; never assume gpu0 on another workstation.
    var pins = String(vitals.readConfig('pinnedMetrics', '')).split(',');
    pins = pins.filter(function(metric) {
        return ['cpu/usage', 'cpu/temp', 'ram/percentage', 'net/down', 'net/up'].indexOf(metric) >= 0
            || /^gpu:[^/]+\/(usage|temp)$/.test(metric);
    });
    if (pins.length === 0) {
        print('KVitals metrics not recognized; left unchanged. Select sensors manually.');
    } else {
        vitals.writeConfig('pinnedMetrics', pins.join(','));
        vitals.writeConfig('fontFamily', 'JetBrainsMono Nerd Font');
        vitals.writeConfig('fontSize', 14);
        vitals.writeConfig('fontBold', false);
        vitals.writeConfig('iconSize', 14);
        vitals.writeConfig('displayMode', 'text');
        vitals.writeConfig('netLabel', 'NET ↓/↑');
        vitals.writeConfig('mergeFamilyMetrics', true);
        vitals.writeConfig('showSeparators', true);
        vitals.writeConfig('separatorOpacity', 0.28);
        vitals.writeConfig('labelOpacity', 1);
        vitals.writeConfig('useCustomColors', true);
        vitals.writeConfig('iconColor', '#8A62C5');
        vitals.writeConfig('labelColor', '#8A62C5');
        vitals.writeConfig('fontColor', '#E8E6EA');
        vitals.reloadConfig();
        panel.widgets('org.kde.plasma.systemmonitor.diskactivity').forEach(function(w) { w.remove(); });
        print('KVitals refined; CPU/GPU/RAM/network sensor bindings preserved.');
    }
}
