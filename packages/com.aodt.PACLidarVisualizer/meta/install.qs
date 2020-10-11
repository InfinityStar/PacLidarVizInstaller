var targetDirectoryPage = null;
var execName = "PACLidarVisualizer";
var execVersion = "-v1.8.3";

function Component() 
{
    // installer.gainAdminRights();
    component.loaded.connect(this, this.installerLoaded);
    installer.setDefaultPageVisible(QInstaller.LicenseCheck, false);
}

Component.prototype.createOperations = function() 
{
    // Add the desktop and start menu shortcuts.
    component.createOperations();
    if (systemInfo.productType === "windows") {
        component.addOperation("CreateShortcut", "@TargetDir@/"+execName+execVersion+".exe", "@StartMenuDir@/PACLidarVisualizer.lnk",
            "workingDirectory=@TargetDir@", "iconPath=@TargetDir@/PACLidarVisualizer.ico",
            "description=Launch PACLidarVisualizer");  
    }
    if (systemInfo.productType === "windows") {
        component.addOperation("CreateShortcut", "@TargetDir@/"+execName+execVersion+".exe", "@DesktopDir@/PACLidarVisualizer.lnk",
            "workingDirectory=@TargetDir@", "iconPath=@TargetDir@/PACLidarVisualizer.ico",
            "description=Launch PACLidarVisualizer");
    }
}

Component.prototype.installerLoaded = function()
{
    installer.setDefaultPageVisible(QInstaller.TargetDirectory, false);
    installer.addWizardPage(component, "TargetWidget", QInstaller.TargetDirectory);

    targetDirectoryPage = gui.pageWidgetByObjectName("DynamicTargetWidget");
    targetDirectoryPage.windowTitle = "选择要安装的文件夹";
    targetDirectoryPage.description.setText("请选择PAC Lidar Visualizer将要安装的位置:");
    targetDirectoryPage.targetDirectory.textChanged.connect(this, this.targetDirectoryChanged);
    targetDirectoryPage.targetDirectory.setText(installer.value("TargetDir"));
    targetDirectoryPage.targetChooser.released.connect(this, this.targetChooserClicked);

    gui.pageById(QInstaller.ComponentSelection).entered.connect(this, this.componentSelectionPageEntered);
}

Component.prototype.targetChooserClicked = function()
{
    var dir = QFileDialog.getExistingDirectory("", targetDirectoryPage.targetDirectory.text);
    targetDirectoryPage.targetDirectory.setText(dir);
}

var optionNum = 0;

Component.prototype.targetDirectoryChanged = function()
{
    var dir = targetDirectoryPage.targetDirectory.text;
    if (installer.fileExists(dir) && installer.fileExists(dir + "/maintenancetool.exe")) 
    {
        if(installer.fileExists(dir+"/"+execName+".ico"))
        {
            if(installer.fileExists(dir+"/"+execName+execVersion+".exe")){
                targetDirectoryPage.warning.setText("<p style=\"color: red\">检测到相同版本的程序已安装,继续进行将重新安装</p>");
                optionNum = 1;
            }
            else{
                targetDirectoryPage.warning.setText("<p style=\"color: red\">检测到此文件夹已有不同版本的程序,继续进行将覆盖安装</p>");
                optionNum = 1;
            }
        }
        else{
            targetDirectoryPage.warning.setText("<p style=\"color: red\">检测到此文件夹已有安装的其他程序,请重新选择文件夹</p>");
            optionNum = 2;
        }
    }
    else if (installer.fileExists(dir)) {
            targetDirectoryPage.warning.setText("<p style=\"color: red\">注意:此文件夹已存在,这会导致卸载此程序时删除此文件夹</p>");
            optionNum = 0;
    }
    else {
        targetDirectoryPage.warning.setText("");
        optionNum = 0;
    }
    installer.setValue("TargetDir", dir);
}

Component.prototype.componentSelectionPageEntered = function()
{
    var dir = installer.value("TargetDir");
    if (optionNum == 1) {
            installer.execute(dir + "/maintenancetool.exe", "--script=" + dir + "/script/auto_uninstall.qs");
    }
    else if(optionNum == 2){

        var result = QMessageBox.question("quit.question", "Installer", "文件夹错误，确定中止安装吗?",
                                  QMessageBox.Yes | QMessageBox.No);
        if (result == QMessageBox.Yes) {
            installer.setValue("FinishedText", "<font color='red' size=3>安装程序已中止.</font>");
            // installer.setDefaultPageVisible(QInstaller.TargetDirectory, false);
            installer.setDefaultPageVisible(QInstaller.ReadyForInstallation, false);
            installer.setDefaultPageVisible(QInstaller.ComponentSelection, false);
            installer.setDefaultPageVisible(QInstaller.StartMenuSelection, false);
            installer.setDefaultPageVisible(QInstaller.PerformInstallation, false);
            installer.setDefaultPageVisible(QInstaller.LicenseCheck, false);
            gui.clickButton(buttons.NextButton);
        }
        else{
            gui.clickButton(buttons.BackButton);
        }
    }
}