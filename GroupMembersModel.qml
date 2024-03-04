import QtQuick 2.15
import QtQuick.LocalStorage 2.15

ListModel {
    id: groupMembersModel

    // Function to fetch users from a specific group using a command
    function loadUsersFromGroup(groupName) {
        var process = Qt.createQmlObject('import QtQuick 2.15; QtObject{}', Qt.application);

        // Execute the command and capture its output
        process.setProperty('script', 'getent group ' + groupName + ' | cut -d: -f4');
        process.run();

        // Process the command output
        process.onExitCodeChanged: {
            if (process.exitCode === 0) {
                // Clear existing data
                clear();

                // Split the comma-separated list of users
                var users = process.standardOutput.split(',');

                // Add users to the model
                for (var i = 0; i < users.length; ++i) {
                    append({username: users[i]});
                }
            } else {
                console.error('Error executing command: ' + process.exitCode);
            }
        }
    }
}