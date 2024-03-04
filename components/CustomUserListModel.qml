import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Process 1.3

ListModel {
    id: customUserListModel

    property string groupName: "people" // Specify the group name

    function loadUsersFromGroup() {
        var process = Qt.createQmlObject('import QtQuick.Process 1.3; Process { }', customUserListModel);
        
        // Execute the command and capture its output
        process.start('getent', ['group', groupName]);
        process.waitForFinished();

        // Parse the output and update the model
        var output = process.readAllStandardOutput().toString().trim();
        var users = output.split(':')[3].split(',');

        // Clear existing data
        clear();

        // Add users to the model
        for (var i = 0; i < users.length; ++i) {
            append({ username: users[i] });
        }
    }
}