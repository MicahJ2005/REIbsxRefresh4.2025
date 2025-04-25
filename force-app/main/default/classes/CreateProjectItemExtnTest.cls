@isTest
/**
    Name        : CreateProjectItemExtnTest
    Date        : April 12, 2019
    Author      : Shweta Fulara(Cmentor)
    Description : This test class is used for code coverage of CreateProjectItemExtn.
**/
private class CreateProjectItemExtnTest {
    @testSetup
    static void setup() {
        String orgId = userInfo.getOrganizationId();
        String salesRepEmail = 'testing@test' + orgId + '.org';
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email= salesRepEmail, 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName=salesRepEmail);
        
        insert u; 
        
        Account accVendor = TestDataFactory.createAccount(
            'Investor acc',
            Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
                .get('Vendor')
                .getRecordTypeId(),
            ''
        );
        insert accVendor;

        Contact conVendor = TestDataFactory.createContact(
            'Vendor',
            'Tester',
            '9879654321',
            'testaccVendorsf@tester.com',
            accVendor.Id,
            Schema.SObjectType.Contact.getRecordTypeInfosByName()
                .get('Vendor')
                .getRecordTypeId()
        );

        insert conVendor;

        Account accInvestor = TestDataFactory.createAccount(
            'Investor acc',
            Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
                .get('Investor')
                .getRecordTypeId(),
            ''
        );
        insert accInvestor;

        Contact conInvestor = TestDataFactory.createContact(
            'Investor',
            'Tester',
            '9879654321',
            'testInvestorsf@tester.com',
            accInvestor.Id,
            Schema.SObjectType.Contact.getRecordTypeInfosByName()
                .get('Investor')
                .getRecordTypeId()
        );
        insert conInvestor;

        House__c house = TestDataFactory.createHouse(
            'Test Property',
            'Test Property',
            'Test Streeet',
            'Memphis',
            'TN',
            '39876',
            'US'
        );
        house.Investor__c = accInvestor.Id;
        insert house;

        Account acc = TestDataFactory.createAccount(
            'Owner acc',
            Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
                .get('Resident')
                .getRecordTypeId(),
            ''
        );
        insert acc;

        Contact con = TestDataFactory.createContact(
            'Test',
            'Tester',
            '9879654321',
            'testsf@tester.com',
            acc.Id,
            Schema.SObjectType.Contact.getRecordTypeInfosByName()
                .get('Resident')
                .getRecordTypeId()
        );
        insert con;

        Schema.DescribeFieldResult catGlobal = SObjectType.Case.fields.CategoryGlobal__c;
        List<Schema.PicklistEntry> categoryEntries = catGlobal.getPicklistValues();

        Case cs = TestDataFactory.createCase(
            Schema.SObjectType.Case.getRecordTypeInfosByName()
                .get('Maintenance')
                .getRecordTypeId(),
            'Open',
            con.Id,
            house.Id,
            'Test desc.',
            '9998887878',
            System.now(),
            false,
            System.now().addMonths(1),
            categoryEntries[0].getValue()
        );
        insert cs;

        /*     Id renovationProjectRecTypeId = Schema.SObjectType.Project__c.getRecordTypeInfosByName().get('Renovation').getRecordTypeId();
         
        
        Project__c projectRen = new Project__c(House__c=house.Id, Lease_Closing__c=System.today().addDays(-20),
                                                    Description__c='Test desc.', Account__c= accInvestor.Id,
                                                    Case__c=cs.Id, RecordTypeId=renovationProjectRecTypeId);

        insert projectren;      
 */
        Id maintenanceProjectRecTypeId = Schema.SObjectType.Project__c.getRecordTypeInfosByName()
            .get('Maintenance')
            .getRecordTypeId();

        Project__c project = new Project__c(
            House__c = house.Id,
            Description__c = 'Test desc.',
            Account__c = acc.Id,
            Case__c = cs.Id,
            RecordTypeId = maintenanceProjectRecTypeId
        );
        project.Asking_Price__c = 18500;
        //  project.Downpayment__c = 25;
        //  project.Interest_Rate__c = 4.25;
        //  project.Mortgage_Year__c = '30';
        project.Vacancy_Rate__c = 4.0;
        project.Maintenance_Rate__c = 4.0;
        project.Rent_Assumption_for_Calculations__c = 1245;
        project.Estimated_Annual_Property_Taxes__c = 1394;
        project.Estimated_Annual_HOA_Dues__c = 435;
        project.Estimated_Annual_Management_Fee_10__c = 1494;
        project.Estimated_Annual_Homeowners_Insurance__c = 754;
        project.Appreciation_Rate__c = 1.0;
        project.Lease_Closing__c = date.today() + 3;
        insert project;

        Project_Item__c projectItem = new Project_Item__c(
            Project__c = project.Id,
            Case__c = cs.Id,
            Description__c = 'Test desc.',
            Maintenance_Status__c = 'Dispatched',
            MaintenanceCategoryGlobal__c = 'Flooring',
            MaintenanceSubCategoryGlobal__c = 'Water Extraction',
            Name = 'WO-MEM-00001303-01'
        );
        insert projectItem;

        ContentVersion cv = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'testing',
            VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body')
        );
        insert cv;

        List<ContentVersion> cvList = [
            SELECT Id, Title, ContentDocumentId
            FROM ContentVersion
            WHERE Id = :cv.Id
        ];

        //create ContentDocumentLink  record
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = projectItem.id;
        cdl.ContentDocumentId = cvList[0].ContentDocumentId;
        cdl.shareType = 'V';
        insert cdl;

        Project_Item_Bid__c bid = new Project_Item_Bid__c(
            Project_Item__c = projectItem.Id,
            SOW_Description__c = 'sow test',
            Owner_Accepted__c = true
        );
        insert bid;

        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser) {
            UserRole r = [
                SELECT Id
                FROM UserRole
                WHERE DeveloperName = 'CustomerService'
            ];

            String dateString = String.valueof(Datetime.now())
                .replace(' ', '')
                .replace(':', '')
                .replace('-', '');
            Integer randomInt = Integer.valueOf(
                math.rint(math.random() * 1000000)
            );
            String uniqueName = orgId + dateString + randomInt;
            User tuser = new User(
                firstname = 'Test',
                lastName = 'LastNm',
                email = 'testing@test' + orgId + '.org',
                Username = uniqueName + '@test' + orgId + '.org',
                EmailEncodingKey = 'ISO-8859-1',
                Alias = uniqueName.substring(18, 23),
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                ProfileId = [
                    SELECT Id
                    FROM Profile
                    WHERE Name = 'System Administrator'
                ]
                .Id,
                UserRoleId = r.Id
            );
            insert tuser;

            accInvestor.Customer_Service_Assignment__c = tuser.Id;
            update accInvestor;
        }
    }

    @isTest
    static void testMethod1() {
        System.debug('testMethod1');

        Case cs = [SELECT Id FROM Case LIMIT 1];
        Account accVendor = [
            SELECT Id, Name
            FROM Account
            WHERE RecordType.Name = 'Vendor'
            LIMIT 1
        ];

        Project_Item__c projectItem = [SELECT Id FROM Project_Item__c LIMIT 1];

        ContentVersion proItemCv = [
            SELECT Id, Title
            FROM ContentVersion
            LIMIT 1
        ];

        PageReference pageRef = Page.CreateProjectItem;
        Test.setCurrentPage(pageRef);

        ApexPages.currentPage().getParameters().put('id', cs.Id);

        CreateProjectItemExtn projectItemCreate = new CreateProjectItemExtn();

        projectItemCreate.getOVER_400();
        projectItemCreate.getOver400Status();
        projectItemCreate.getMaintenanceStatus();
        projectItemCreate.getMaintenanceCategory();
        projectItemCreate.getMaintenanceSubCategory();
        projectItemCreate.getYesNo();
        projectItemCreate.getFileLocation();
        projectItemCreate.refreshDocumentSection();

        projectItemCreate.selectedDocumentFolder = 'Notes & Attachments';
        projectItemCreate.docWrapList = new List<CreateProjectItemExtn.DocumentWrapper>();
        CreateProjectItemExtn.DocumentWrapper docWrap = new CreateProjectItemExtn.DocumentWrapper(
            true,
            proItemCv.Id,
            proItemCv.Title
        );
        projectItemCreate.docWrapList.add(docWrap);
        projectItemCreate.attachFile();

        ContentVersion cv = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'testing',
            VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body')
        );
        insert cv;

        projectItemCreate.newFileId = cv.Id;
        projectItemCreate.selectedDocumentFolder = 'My Computer';
        projectItemCreate.attachFile();
        projectItemCreate.rowIndexAttach = '0';
        projectItemCreate.deleteAttachment();

        projectItemCreate.saveProjectItem();

        projectItemCreate.projectItem.Maintenance_Status__c = 'Dispatched';
        projectItemCreate.checkBids();
        projectItemCreate.rowIndexAttach = '0';
        projectItemCreate.deleteAttachment();

        projectItemCreate.projectItem.Maintenance_Status__c = 'Completed';
        projectItemCreate.checkBids();

        projectItemCreate.checkPriority();

        projectItemCreate.projectItem.MaintenanceCategoryGlobal__c = 'Flooring';
        projectItemCreate.checkPriority();

        projectItemCreate.projectItem.MaintenanceCategoryGlobal__c = 'Flooring';
        projectItemCreate.projectItem.MaintenanceSubCategoryGlobal__c = 'Water Extraction';
        projectItemCreate.checkPriority();
        System.assertEquals(
            projectItemCreate.projectItem.Priority__c,
            'Critical'
        );

        projectItemCreate.projectItem.MaintenanceSubCategoryGlobal__c = 'Subfloor';
        projectItemCreate.checkPriority();
        System.assertEquals(
            projectItemCreate.projectItem.Priority__c,
            'Urgent'
        );

        projectItemCreate.projectItem.MaintenanceSubCategoryGlobal__c = 'Hardwood';
        projectItemCreate.checkPriority();
        System.assertEquals(projectItemCreate.projectItem.Priority__c, 'High');

        projectItemCreate.projectItem.MaintenanceSubCategoryGlobal__c = 'Sanding/Finishing';
        projectItemCreate.checkPriority();
        System.assertEquals(
            projectItemCreate.projectItem.Priority__c,
            'Medium'
        );

        projectItemCreate.projectItem.MaintenanceCategoryGlobal__c = 'Plumbing';
        projectItemCreate.projectItem.MaintenanceSubCategoryGlobal__c = 'Water Extraction';
        projectItemCreate.checkPriority();
        System.assertEquals(
            projectItemCreate.projectItem.Priority__c,
            'Critical'
        );

        projectItemCreate.projectItem.MaintenanceCategoryGlobal__c = 'HVAC';
        projectItemCreate.projectItem.MaintenanceSubCategoryGlobal__c = 'Furnace Installation';
        projectItemCreate.checkPriority();
        System.assertEquals(
            projectItemCreate.projectItem.Priority__c,
            'Critical'
        );

        projectItemCreate.saveProjectItem();

        projectItemCreate.projectItem.Maintenance_Status__c = 'Dispatched';
        projectItemCreate.selectedButton = 'Save';
        projectItemCreate.bidWrapperList[0].bid.SOW_Description__c = 'Test';
        projectItemCreate.bidWrapperList[0].bid.Vendor__c = accVendor.Id;
        PageReference pgRef = projectItemCreate.saveProjectItem();

        projectItemCreate.numberOfBids = 1;
        projectItemCreate.bidTotalList();

        projectItemCreate.numberOfBids = 3;
        projectItemCreate.bidTotalList();

        projectItemCreate.numberOfBids = 2;
        projectItemCreate.bidTotalList();

        projectItemCreate.acceptedRow = '0';
        projectItemCreate.bidAcceptedByOwner();

        System.assertEquals(
            projectItemCreate.projectItem.Total_Repair_Cost__c <
            projectItemCreate.getOVER_400(),
            true
        );

        projectItemCreate.selectedButton = 'SaveNew';
        projectItemCreate.bidWrapperList[0].bid.SOW_Description__c = 'Test';
        projectItemCreate.bidWrapperList[0].bid.Vendor__c = accVendor.Id;
        projectItemCreate.bidWrapperList[0].bid.Repair_Cost__c = 50;

        projectItemCreate.numberOfBids = 2;
        projectItemCreate.bidTotalList();

        PageReference pgRef1 = projectItemCreate.saveProjectItem();

        projectItemCreate.bidWrapperList[0].bid.SOW_Description__c = 'Test';
        projectItemCreate.bidWrapperList[0].bid.Vendor__c = accVendor.Id;
        projectItemCreate.bidWrapperList[0].bid.Repair_Cost__c = 500;
        projectItemCreate.acceptedRow = '0';
        projectItemCreate.projectItem.Over_400_Status__c = 'Over $400 Post-work Notification (QOL)';
        projectItemCreate.bidAcceptedByOwner();
        projectItemCreate.saveProjectItem();
        System.assertEquals(
            projectItemCreate.projectItem.Total_Repair_Cost__c >
            projectItemCreate.getOVER_400(),
            true
        );
        for (
            CreateProjectItemExtn.BidWrapper bidWrap : projectItemCreate.bidWrapperList
        ) {
            bidWrap.bid.Project_Item__c = projectItem.Id;
        }

        String orgId = userInfo.getOrganizationId();
        projectItemCreate.salesRepEmail = 'testing@test' + orgId + '.org';
        projectItemCreate.sendEmail();

        projectItemCreate.closePopupModal();
        projectItemCreate.cancel();
        projectItemCreate.refreshDocumentSection1();
    }

    @isTest
    static void testMoveOutProject() {
        Case cs = [SELECT Id, Property__c FROM Case LIMIT 1];
        Account accVendor = [
            SELECT Id, Name
            FROM Account
            WHERE RecordType.Name = 'Vendor'
            LIMIT 1
        ];

        Project_Item__c projectItem = [SELECT Id FROM Project_Item__c LIMIT 1];

        ContentVersion proItemCv = [
            SELECT Id, Title
            FROM ContentVersion
            LIMIT 1
        ];

        delete [SELECT Id FROM Project__c WHERE Case__c = :cs.Id];

        Id moveOutProjectRecTypeId = Schema.SObjectType.Project__c.getRecordTypeInfosByName()
            .get('Move Out')
            .getRecordTypeId();

        Project__c moveOutProject = new Project__c(
            House__c = cs.Property__c,
            Account__c = accVendor.Id,
            Case__c = cs.Id,
            RecordTypeId = moveOutProjectRecTypeId,
            Lease_Closing__c = date.today() + 3
        );

        insert moveOutProject;

        PageReference pageRef = Page.CreateProjectItem;
        Test.setCurrentPage(pageRef);

        ApexPages.currentPage().getParameters().put('id', cs.Id);

        CreateProjectItemExtn projectItemCreate = new CreateProjectItemExtn();

        projectItemCreate.getOVER_400();
        projectItemCreate.getOver400Status();
        projectItemCreate.getMaintenanceStatus();
        projectItemCreate.getMaintenanceCategory();
        projectItemCreate.getMaintenanceSubCategory();
        projectItemCreate.getYesNo();
        projectItemCreate.getFileLocation();
        projectItemCreate.refreshDocumentSection();

        projectItemCreate.selectedDocumentFolder = 'Notes & Attachments';
        projectItemCreate.docWrapList = new List<CreateProjectItemExtn.DocumentWrapper>();
        CreateProjectItemExtn.DocumentWrapper docWrap = new CreateProjectItemExtn.DocumentWrapper(
            true,
            proItemCv.Id,
            proItemCv.Title
        );
        projectItemCreate.docWrapList.add(docWrap);
        projectItemCreate.attachFile();

        ContentVersion cv = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'testing',
            VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body')
        );
        insert cv;

        projectItemCreate.newFileId = cv.Id;
        projectItemCreate.selectedDocumentFolder = 'My Computer';
        projectItemCreate.attachFile();
        projectItemCreate.rowIndexAttach = '0';
        projectItemCreate.deleteAttachment();

        projectItemCreate.saveProjectItem();

        projectItemCreate.projectItem.Maintenance_Status__c = 'Dispatched';
        projectItemCreate.checkBids();
        projectItemCreate.rowIndexAttach = '0';
        projectItemCreate.deleteAttachment();

        projectItemCreate.projectItem.Maintenance_Status__c = 'Completed';
        projectItemCreate.checkBids();

        projectItemCreate.checkPriority();

        projectItemCreate.projectItem.MaintenanceCategoryGlobal__c = 'Flooring';
        projectItemCreate.checkPriority();

        projectItemCreate.projectItem.MaintenanceCategoryGlobal__c = 'Flooring';
        projectItemCreate.projectItem.MaintenanceSubCategoryGlobal__c = 'Water Extraction';
        projectItemCreate.checkPriority();
        System.assertEquals(
            projectItemCreate.projectItem.Priority__c,
            'Critical'
        );

        projectItemCreate.projectItem.MaintenanceSubCategoryGlobal__c = 'Subfloor';
        projectItemCreate.checkPriority();
        System.assertEquals(
            projectItemCreate.projectItem.Priority__c,
            'Urgent'
        );

        projectItemCreate.projectItem.MaintenanceSubCategoryGlobal__c = 'Hardwood';
        projectItemCreate.checkPriority();
        System.assertEquals(projectItemCreate.projectItem.Priority__c, 'High');

        projectItemCreate.projectItem.MaintenanceSubCategoryGlobal__c = 'Sanding/Finishing';
        projectItemCreate.checkPriority();
        System.assertEquals(
            projectItemCreate.projectItem.Priority__c,
            'Medium'
        );

        projectItemCreate.projectItem.MaintenanceCategoryGlobal__c = 'Plumbing';
        projectItemCreate.projectItem.MaintenanceSubCategoryGlobal__c = 'Water Extraction';
        projectItemCreate.checkPriority();
        System.assertEquals(
            projectItemCreate.projectItem.Priority__c,
            'Critical'
        );

        projectItemCreate.projectItem.MaintenanceCategoryGlobal__c = 'HVAC';
        projectItemCreate.projectItem.MaintenanceSubCategoryGlobal__c = 'Furnace Installation';
        projectItemCreate.checkPriority();
        System.assertEquals(
            projectItemCreate.projectItem.Priority__c,
            'Critical'
        );

        projectItemCreate.saveProjectItem();

        projectItemCreate.projectItem.Maintenance_Status__c = 'Dispatched';
        projectItemCreate.selectedButton = 'Save';
        projectItemCreate.bidWrapperList[0].bid.SOW_Description__c = 'Test';
        projectItemCreate.bidWrapperList[0].bid.Vendor__c = accVendor.Id;
        PageReference pgRef = projectItemCreate.saveProjectItem();

        projectItemCreate.numberOfBids = 1;
        projectItemCreate.bidTotalList();

        projectItemCreate.numberOfBids = 3;
        projectItemCreate.bidTotalList();

        projectItemCreate.numberOfBids = 2;
        projectItemCreate.bidTotalList();

        projectItemCreate.acceptedRow = '0';
        projectItemCreate.bidAcceptedByOwner();

        System.assertEquals(
            projectItemCreate.projectItem.Total_Repair_Cost__c <
            projectItemCreate.getOVER_400(),
            true
        );

        projectItemCreate.selectedButton = 'SaveNew';
        projectItemCreate.bidWrapperList[0].bid.SOW_Description__c = 'Test';
        projectItemCreate.bidWrapperList[0].bid.Vendor__c = accVendor.Id;
        projectItemCreate.bidWrapperList[0].bid.Repair_Cost__c = 50;

        projectItemCreate.numberOfBids = 2;
        projectItemCreate.bidTotalList();

        PageReference pgRef1 = projectItemCreate.saveProjectItem();

        projectItemCreate.bidWrapperList[0].bid.SOW_Description__c = 'Test';
        projectItemCreate.bidWrapperList[0].bid.Vendor__c = accVendor.Id;
        projectItemCreate.bidWrapperList[0].bid.Repair_Cost__c = 500;
        projectItemCreate.acceptedRow = '0';
        projectItemCreate.projectItem.Over_400_Status__c = 'Over $400 Post-work Notification (QOL)';
        projectItemCreate.bidAcceptedByOwner();
        projectItemCreate.saveProjectItem();
        System.assertEquals(
            projectItemCreate.projectItem.Total_Repair_Cost__c >
            projectItemCreate.getOVER_400(),
            true
        );
        for (
            CreateProjectItemExtn.BidWrapper bidWrap : projectItemCreate.bidWrapperList
        ) {
            bidWrap.bid.Project_Item__c = projectItem.Id;
        }

        String orgId = userInfo.getOrganizationId();
        projectItemCreate.salesRepEmail = 'testing@test' + orgId + '.org';
        //projectItemCreate.sendEmail();

        projectItemCreate.closePopupModal();
        projectItemCreate.cancel();
        projectItemCreate.refreshDocumentSection1();
    }

    @isTest
    static void testRenovationProject() {
        Case cs = [SELECT Id, Property__c FROM Case LIMIT 1];
        Account accVendor = [
            SELECT Id, Name
            FROM Account
            WHERE RecordType.Name = 'Vendor'
            LIMIT 1
        ];

        Project_Item__c projectItem = [SELECT Id FROM Project_Item__c LIMIT 1];

        ContentVersion proItemCv = [
            SELECT Id, Title
            FROM ContentVersion
            LIMIT 1
        ];

        delete [SELECT Id FROM Project__c WHERE Case__c = :cs.Id];

        Id renoProjectRecTypeId = Schema.SObjectType.Project__c.getRecordTypeInfosByName()
            .get('Renovation')
            .getRecordTypeId();

        Project__c renoProject = new Project__c(
            House__c = cs.Property__c,
            Account__c = accVendor.Id,
            Case__c = cs.Id,
            RecordTypeId = renoProjectRecTypeId,
            Lease_Closing__c = date.today() + 3,
            Pay_Account__c = 'New DFW'
        );

        insert renoProject;

        PageReference pageRef = Page.CreateProjectItem;
        Test.setCurrentPage(pageRef);

        ApexPages.currentPage().getParameters().put('id', cs.Id);

        CreateProjectItemExtn projectItemCreate = new CreateProjectItemExtn();

        projectItemCreate.getOVER_400();
        projectItemCreate.getOver400Status();
        projectItemCreate.getMaintenanceStatus();
        projectItemCreate.getMaintenanceCategory();
        projectItemCreate.getMaintenanceSubCategory();
        projectItemCreate.getYesNo();
        projectItemCreate.getFileLocation();
        projectItemCreate.refreshDocumentSection();

        projectItemCreate.selectedDocumentFolder = 'Notes & Attachments';
        projectItemCreate.docWrapList = new List<CreateProjectItemExtn.DocumentWrapper>();
        CreateProjectItemExtn.DocumentWrapper docWrap = new CreateProjectItemExtn.DocumentWrapper(
            true,
            proItemCv.Id,
            proItemCv.Title
        );
        projectItemCreate.docWrapList.add(docWrap);
        projectItemCreate.attachFile();

        ContentVersion cv = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'testing',
            VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body')
        );
        insert cv;

        projectItemCreate.newFileId = cv.Id;
        projectItemCreate.selectedDocumentFolder = 'My Computer';
        projectItemCreate.attachFile();
        projectItemCreate.rowIndexAttach = '0';
        projectItemCreate.deleteAttachment();

        projectItemCreate.saveProjectItem();

        projectItemCreate.projectItem.Maintenance_Status__c = 'Dispatched';
        projectItemCreate.checkBids();
        projectItemCreate.rowIndexAttach = '0';
        projectItemCreate.deleteAttachment();

        projectItemCreate.projectItem.Maintenance_Status__c = 'Completed';
        projectItemCreate.checkBids();

        projectItemCreate.checkPriority();

        projectItemCreate.projectItem.MaintenanceCategoryGlobal__c = 'Flooring';
        projectItemCreate.checkPriority();

        projectItemCreate.projectItem.MaintenanceCategoryGlobal__c = 'Flooring';
        projectItemCreate.projectItem.MaintenanceSubCategoryGlobal__c = 'Water Extraction';
        projectItemCreate.checkPriority();
        System.assertEquals(
            projectItemCreate.projectItem.Priority__c,
            'Critical'
        );

        projectItemCreate.projectItem.MaintenanceSubCategoryGlobal__c = 'Subfloor';
        projectItemCreate.checkPriority();
        System.assertEquals(
            projectItemCreate.projectItem.Priority__c,
            'Urgent'
        );

        projectItemCreate.projectItem.MaintenanceSubCategoryGlobal__c = 'Hardwood';
        projectItemCreate.checkPriority();
        System.assertEquals(projectItemCreate.projectItem.Priority__c, 'High');

        projectItemCreate.projectItem.MaintenanceSubCategoryGlobal__c = 'Sanding/Finishing';
        projectItemCreate.checkPriority();
        System.assertEquals(
            projectItemCreate.projectItem.Priority__c,
            'Medium'
        );

        projectItemCreate.projectItem.MaintenanceCategoryGlobal__c = 'Plumbing';
        projectItemCreate.projectItem.MaintenanceSubCategoryGlobal__c = 'Water Extraction';
        projectItemCreate.checkPriority();
        System.assertEquals(
            projectItemCreate.projectItem.Priority__c,
            'Critical'
        );

        projectItemCreate.projectItem.MaintenanceCategoryGlobal__c = 'HVAC';
        projectItemCreate.projectItem.MaintenanceSubCategoryGlobal__c = 'Furnace Installation';
        projectItemCreate.checkPriority();
        System.assertEquals(
            projectItemCreate.projectItem.Priority__c,
            'Critical'
        );

        projectItemCreate.saveProjectItem();

        projectItemCreate.projectItem.Maintenance_Status__c = 'Dispatched';
        projectItemCreate.selectedButton = 'Save';
        projectItemCreate.bidWrapperList[0].bid.SOW_Description__c = 'Test';
        projectItemCreate.bidWrapperList[0].bid.Vendor__c = accVendor.Id;
        PageReference pgRef = projectItemCreate.saveProjectItem();

        projectItemCreate.numberOfBids = 1;
        projectItemCreate.bidTotalList();

        projectItemCreate.numberOfBids = 3;
        projectItemCreate.bidTotalList();

        projectItemCreate.numberOfBids = 2;
        projectItemCreate.bidTotalList();

        projectItemCreate.acceptedRow = '0';
        projectItemCreate.bidAcceptedByOwner();

        System.assertEquals(
            projectItemCreate.projectItem.Total_Repair_Cost__c <
            projectItemCreate.getOVER_400(),
            true
        );

        projectItemCreate.selectedButton = 'SaveNew';
        projectItemCreate.bidWrapperList[0].bid.SOW_Description__c = 'Test';
        projectItemCreate.bidWrapperList[0].bid.Vendor__c = accVendor.Id;
        projectItemCreate.bidWrapperList[0].bid.Repair_Cost__c = 50;

        projectItemCreate.numberOfBids = 2;
        projectItemCreate.bidTotalList();

        PageReference pgRef1 = projectItemCreate.saveProjectItem();

        projectItemCreate.bidWrapperList[0].bid.SOW_Description__c = 'Test';
        projectItemCreate.bidWrapperList[0].bid.Vendor__c = accVendor.Id;
        projectItemCreate.bidWrapperList[0].bid.Repair_Cost__c = 500;
        projectItemCreate.acceptedRow = '0';
        projectItemCreate.projectItem.Over_400_Status__c = 'Over $400 Post-work Notification (QOL)';
        projectItemCreate.bidAcceptedByOwner();
        projectItemCreate.saveProjectItem();
        System.assertEquals(
            projectItemCreate.projectItem.Total_Repair_Cost__c >
            projectItemCreate.getOVER_400(),
            true
        );
        for (
            CreateProjectItemExtn.BidWrapper bidWrap : projectItemCreate.bidWrapperList
        ) {
            bidWrap.bid.Project_Item__c = projectItem.Id;
        }

        String orgId = userInfo.getOrganizationId();
        projectItemCreate.salesRepEmail = 'testing@test' + orgId + '.org';
        //projectItemCreate.sendEmail();

        projectItemCreate.closePopupModal();
        projectItemCreate.cancel();
        projectItemCreate.refreshDocumentSection1();
    }

    @isTest
    static void testMethod1_2() {
        System.debug('testMethod1_2');
        Case cs = [SELECT Id, Property__c FROM Case LIMIT 1];
        Account accVendor = [
            SELECT Id, Name
            FROM Account
            WHERE RecordType.Name = 'Vendor'
            LIMIT 1
        ];

        Project_Item__c projectItem = [SELECT Id FROM Project_Item__c LIMIT 1];

        ContentVersion proItemCv = [
            SELECT Id, Title
            FROM ContentVersion
            LIMIT 1
        ];

        Project__c project = [
            SELECT Id, House__c
            FROM Project__c
            WHERE Case__c = :cs.Id
            LIMIT 1
        ];

        House__c house = new House__c(Name = '6805 Springtree Ln');
        insert house;
        project.House__c = house.Id;
        update project;

        PageReference pageRef = Page.CreateProjectItem;
        Test.setCurrentPage(pageRef);

        ApexPages.currentPage().getParameters().put('id', cs.Id);

        CreateProjectItemExtn projectItemCreate = new CreateProjectItemExtn();

        projectItemCreate.getOVER_400();
        projectItemCreate.getOver400Status();
        projectItemCreate.getMaintenanceStatus();
        projectItemCreate.getMaintenanceCategory();
        projectItemCreate.getMaintenanceSubCategory();
        projectItemCreate.getYesNo();
        projectItemCreate.getFileLocation();
        projectItemCreate.refreshDocumentSection();

        projectItemCreate.selectedDocumentFolder = 'Notes & Attachments';
        projectItemCreate.docWrapList = new List<CreateProjectItemExtn.DocumentWrapper>();
        CreateProjectItemExtn.DocumentWrapper docWrap = new CreateProjectItemExtn.DocumentWrapper(
            true,
            proItemCv.Id,
            proItemCv.Title
        );
        projectItemCreate.docWrapList.add(docWrap);
        projectItemCreate.attachFile();

        ContentVersion cv = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'testing',
            VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body')
        );
        insert cv;

        projectItemCreate.newFileId = cv.Id;
        projectItemCreate.selectedDocumentFolder = 'My Computer';
        projectItemCreate.attachFile();
        projectItemCreate.rowIndexAttach = '0';
        projectItemCreate.deleteAttachment();

        projectItemCreate.saveProjectItem();

        projectItemCreate.projectItem.Maintenance_Status__c = 'Dispatched';
        projectItemCreate.checkBids();
        projectItemCreate.rowIndexAttach = '0';
        projectItemCreate.deleteAttachment();

        projectItemCreate.projectItem.Maintenance_Status__c = 'Completed';
        projectItemCreate.checkBids();

        projectItemCreate.checkPriority();

        projectItemCreate.projectItem.MaintenanceCategoryGlobal__c = 'Flooring';
        projectItemCreate.checkPriority();

        projectItemCreate.projectItem.MaintenanceCategoryGlobal__c = 'Flooring';
        projectItemCreate.projectItem.MaintenanceSubCategoryGlobal__c = 'Water Extraction';
        projectItemCreate.checkPriority();
        System.assertEquals(
            projectItemCreate.projectItem.Priority__c,
            'Critical'
        );

        projectItemCreate.projectItem.MaintenanceSubCategoryGlobal__c = 'Subfloor';
        projectItemCreate.checkPriority();
        System.assertEquals(
            projectItemCreate.projectItem.Priority__c,
            'Urgent'
        );

        projectItemCreate.projectItem.MaintenanceSubCategoryGlobal__c = 'Hardwood';
        projectItemCreate.checkPriority();
        System.assertEquals(projectItemCreate.projectItem.Priority__c, 'High');

        projectItemCreate.projectItem.MaintenanceSubCategoryGlobal__c = 'Sanding/Finishing';
        projectItemCreate.checkPriority();
        System.assertEquals(
            projectItemCreate.projectItem.Priority__c,
            'Medium'
        );

        projectItemCreate.projectItem.MaintenanceCategoryGlobal__c = 'Plumbing';
        projectItemCreate.projectItem.MaintenanceSubCategoryGlobal__c = 'Water Extraction';
        projectItemCreate.checkPriority();
        System.assertEquals(
            projectItemCreate.projectItem.Priority__c,
            'Critical'
        );

        projectItemCreate.projectItem.MaintenanceCategoryGlobal__c = 'HVAC';
        projectItemCreate.projectItem.MaintenanceSubCategoryGlobal__c = 'Furnace Installation';
        projectItemCreate.checkPriority();
        System.assertEquals(
            projectItemCreate.projectItem.Priority__c,
            'Critical'
        );

        projectItemCreate.saveProjectItem();

        projectItemCreate.projectItem.Maintenance_Status__c = 'Dispatched';
        projectItemCreate.selectedButton = 'Save';
        projectItemCreate.bidWrapperList[0].bid.SOW_Description__c = 'Test';
        projectItemCreate.bidWrapperList[0].bid.Vendor__c = accVendor.Id;
        PageReference pgRef = projectItemCreate.saveProjectItem();

        projectItemCreate.numberOfBids = 1;
        projectItemCreate.bidTotalList();

        projectItemCreate.numberOfBids = 3;
        projectItemCreate.bidTotalList();

        projectItemCreate.numberOfBids = 2;
        projectItemCreate.bidTotalList();

        projectItemCreate.acceptedRow = '0';
        projectItemCreate.bidAcceptedByOwner();

        System.assertEquals(
            projectItemCreate.projectItem.Total_Repair_Cost__c <
            projectItemCreate.getOVER_400(),
            true
        );

        projectItemCreate.selectedButton = 'SaveNew';
        projectItemCreate.bidWrapperList[0].bid.SOW_Description__c = 'Test';
        projectItemCreate.bidWrapperList[0].bid.Vendor__c = accVendor.Id;
        projectItemCreate.bidWrapperList[0].bid.Repair_Cost__c = 50;

        projectItemCreate.numberOfBids = 2;
        projectItemCreate.bidTotalList();

        PageReference pgRef1 = projectItemCreate.saveProjectItem();

        projectItemCreate.bidWrapperList[0].bid.SOW_Description__c = 'Test';
        projectItemCreate.bidWrapperList[0].bid.Vendor__c = accVendor.Id;
        projectItemCreate.bidWrapperList[0].bid.Repair_Cost__c = 500;
        projectItemCreate.acceptedRow = '0';
        projectItemCreate.projectItem.Over_400_Status__c = 'Over $400 Post-work Notification (QOL)';
        projectItemCreate.bidAcceptedByOwner();
        projectItemCreate.saveProjectItem();
        System.assertEquals(
            projectItemCreate.projectItem.Total_Repair_Cost__c >
            projectItemCreate.getOVER_400(),
            true
        );
        for (
            CreateProjectItemExtn.BidWrapper bidWrap : projectItemCreate.bidWrapperList
        ) {
            bidWrap.bid.Project_Item__c = projectItem.Id;
        }

        String orgId = userInfo.getOrganizationId();
        projectItemCreate.salesRepEmail = 'testing@test' + orgId + '.org';
        //projectItemCreate.sendEmail();

        projectItemCreate.closePopupModal();
        projectItemCreate.cancel();
        projectItemCreate.refreshDocumentSection1();
    }

    @isTest
    static void testMethod2() {
        System.debug('testMethod2');
        Case cs = [SELECT Id, Property__r.Investor__c FROM Case LIMIT 1];

        Account accVendor = [
            SELECT Id, Name
            FROM Account
            WHERE RecordType.Name = 'Vendor'
            LIMIT 1
        ];
        Project_Item__c projectItem = [SELECT Id FROM Project_Item__c LIMIT 1];

        PageReference pageRef = Page.CreateProjectItem;
        Test.setCurrentPage(pageRef);

        ApexPages.currentPage().getParameters().put('id', cs.Id);

        CreateProjectItemExtn projectItemCreate = new CreateProjectItemExtn();

        projectItemCreate.getOVER_400();
        projectItemCreate.getOver400Status();
        projectItemCreate.getMaintenanceStatus();
        projectItemCreate.getMaintenanceCategory();
        projectItemCreate.getMaintenanceSubCategory();
        projectItemCreate.getYesNo();

        projectItemCreate.saveProjectItem();

        projectItemCreate.projectItem.Maintenance_Status__c = 'Dispatched';
        projectItemCreate.checkBids();

        projectItemCreate.projectItem.Maintenance_Status__c = 'Completed';
        projectItemCreate.checkBids();

        projectItemCreate.checkPriority();

        projectItemCreate.projectItem.MaintenanceCategoryGlobal__c = 'Flooring';
        projectItemCreate.checkPriority();

        projectItemCreate.projectItem.MaintenanceCategoryGlobal__c = 'Flooring';
        projectItemCreate.projectItem.MaintenanceSubCategoryGlobal__c = 'Water Extraction';
        projectItemCreate.checkPriority();
        System.assertEquals(
            projectItemCreate.projectItem.Priority__c,
            'Critical'
        );

        projectItemCreate.projectItem.MaintenanceSubCategoryGlobal__c = 'Subfloor';
        projectItemCreate.checkPriority();
        System.assertEquals(
            projectItemCreate.projectItem.Priority__c,
            'Urgent'
        );

        projectItemCreate.projectItem.MaintenanceSubCategoryGlobal__c = 'Hardwood';
        projectItemCreate.checkPriority();
        System.assertEquals(projectItemCreate.projectItem.Priority__c, 'High');

        projectItemCreate.projectItem.MaintenanceSubCategoryGlobal__c = 'Sanding/Finishing';
        projectItemCreate.checkPriority();
        System.assertEquals(
            projectItemCreate.projectItem.Priority__c,
            'Medium'
        );

        projectItemCreate.projectItem.MaintenanceCategoryGlobal__c = 'Plumbing';
        projectItemCreate.projectItem.MaintenanceSubCategoryGlobal__c = 'Water Extraction';
        projectItemCreate.checkPriority();
        System.assertEquals(
            projectItemCreate.projectItem.Priority__c,
            'Critical'
        );

        projectItemCreate.projectItem.MaintenanceCategoryGlobal__c = 'HVAC';
        projectItemCreate.projectItem.MaintenanceSubCategoryGlobal__c = 'Furnace Installation';
        projectItemCreate.checkPriority();
        System.assertEquals(
            projectItemCreate.projectItem.Priority__c,
            'Critical'
        );

        projectItemCreate.saveProjectItem();

        projectItemCreate.projectItem.Maintenance_Status__c = 'Dispatched';
        projectItemCreate.selectedButton = 'Save';
        projectItemCreate.bidWrapperList[0].bid.SOW_Description__c = 'Test';
        projectItemCreate.bidWrapperList[0].bid.Vendor__c = accVendor.Id;
        PageReference pgRef = projectItemCreate.saveProjectItem();

        projectItemCreate.numberOfBids = 1;
        projectItemCreate.bidTotalList();

        projectItemCreate.numberOfBids = 3;
        projectItemCreate.bidTotalList();

        projectItemCreate.numberOfBids = 2;
        projectItemCreate.bidTotalList();

        projectItemCreate.acceptedRow = '0';
        projectItemCreate.bidAcceptedByOwner();

        System.assertEquals(
            projectItemCreate.projectItem.Total_Repair_Cost__c <
            projectItemCreate.getOVER_400(),
            true
        );

        projectItemCreate.selectedButton = 'SaveNew';
        projectItemCreate.bidWrapperList[0].bid.SOW_Description__c = 'Test';
        projectItemCreate.bidWrapperList[0].bid.Vendor__c = accVendor.Id;
        projectItemCreate.bidWrapperList[0].bid.Repair_Cost__c = 50;

        projectItemCreate.numberOfBids = 2;
        projectItemCreate.bidTotalList();

        PageReference pgRef1 = projectItemCreate.saveProjectItem();

        projectItemCreate.bidWrapperList[0].bid.SOW_Description__c = 'Test';
        projectItemCreate.bidWrapperList[0].bid.Vendor__c = accVendor.Id;
        projectItemCreate.bidWrapperList[0].bid.Repair_Cost__c = 500;
        projectItemCreate.acceptedRow = '0';
        projectItemCreate.projectItem.Over_400_Status__c = 'Over $400 Pre-work Approval';
        projectItemCreate.bidAcceptedByOwner();
        projectItemCreate.saveProjectItem();
        System.assertEquals(
            projectItemCreate.projectItem.Total_Repair_Cost__c >
            projectItemCreate.getOVER_400(),
            true
        );
        for (
            CreateProjectItemExtn.BidWrapper bidWrap : projectItemCreate.bidWrapperList
        ) {
            bidWrap.bid.Project_Item__c = projectItem.Id;
        }
        projectItemCreate.sendEmail();

        projectItemCreate.closePopupModal();
        projectItemCreate.cancel();
    }

    @isTest
    static void testPageSave() {
        System.debug('### testPageSave');
        Case cs = [SELECT Id, Property__r.Investor__c FROM Case LIMIT 1];

        Account accVendor = [
            SELECT Id, Name
            FROM Account
            WHERE RecordType.Name = 'Vendor'
            LIMIT 1
        ];
        Project_Item__c projectItem = [SELECT Id FROM Project_Item__c LIMIT 1];

        PageReference pageRef = Page.CreateProjectItem;
        Test.setCurrentPage(pageRef);

        ApexPages.currentPage().getParameters().put('id', cs.Id);

        CreateProjectItemExtn projectItemCreate = new CreateProjectItemExtn();

        projectItemCreate.getOVER_400();
        projectItemCreate.getOver400Status();
        projectItemCreate.getMaintenanceStatus();
        projectItemCreate.getMaintenanceCategory();
        projectItemCreate.getMaintenanceSubCategory();
        projectItemCreate.getYesNo();

        projectItemCreate.saveProjectItem();

        projectItemCreate.projectItem.Maintenance_Status__c = 'Dispatched';
        projectItemCreate.checkBids();

        projectItemCreate.projectItem.Maintenance_Status__c = 'Completed';
        projectItemCreate.checkBids();

        projectItemCreate.checkPriority();

        projectItemCreate.projectItem.MaintenanceCategoryGlobal__c = 'Flooring';
        projectItemCreate.checkPriority();

        projectItemCreate.projectItem.MaintenanceCategoryGlobal__c = 'Flooring';
        projectItemCreate.projectItem.MaintenanceSubCategoryGlobal__c = 'Water Extraction';
        projectItemCreate.checkPriority();
        System.assertEquals(
            projectItemCreate.projectItem.Priority__c,
            'Critical'
        );

        projectItemCreate.projectItem.MaintenanceSubCategoryGlobal__c = 'Subfloor';
        projectItemCreate.checkPriority();
        System.assertEquals(
            projectItemCreate.projectItem.Priority__c,
            'Urgent'
        );

        projectItemCreate.projectItem.MaintenanceSubCategoryGlobal__c = 'Hardwood';
        projectItemCreate.checkPriority();
        System.assertEquals(projectItemCreate.projectItem.Priority__c, 'High');

        projectItemCreate.projectItem.MaintenanceSubCategoryGlobal__c = 'Sanding/Finishing';
        projectItemCreate.checkPriority();
        System.assertEquals(
            projectItemCreate.projectItem.Priority__c,
            'Medium'
        );

        projectItemCreate.projectItem.MaintenanceCategoryGlobal__c = 'Plumbing';
        projectItemCreate.projectItem.MaintenanceSubCategoryGlobal__c = 'Water Extraction';
        projectItemCreate.checkPriority();
        System.assertEquals(
            projectItemCreate.projectItem.Priority__c,
            'Critical'
        );

        projectItemCreate.projectItem.MaintenanceCategoryGlobal__c = 'HVAC';
        projectItemCreate.projectItem.MaintenanceSubCategoryGlobal__c = 'Furnace Installation';
        projectItemCreate.checkPriority();
        System.assertEquals(
            projectItemCreate.projectItem.Priority__c,
            'Critical'
        );

        projectItemCreate.saveProjectItem();

        projectItemCreate.projectItem.Maintenance_Status__c = 'Dispatched';
        projectItemCreate.selectedButton = 'Save';
        projectItemCreate.bidWrapperList[0].bid.SOW_Description__c = 'Test';
        projectItemCreate.bidWrapperList[0].bid.Vendor__c = accVendor.Id;
        PageReference pgRef = projectItemCreate.saveProjectItem();

        projectItemCreate.numberOfBids = 1;
        projectItemCreate.bidTotalList();

        projectItemCreate.numberOfBids = 3;
        projectItemCreate.bidTotalList();

        projectItemCreate.numberOfBids = 2;
        projectItemCreate.bidTotalList();

        projectItemCreate.acceptedRow = '0';
        projectItemCreate.bidAcceptedByOwner();

        System.assertEquals(
            projectItemCreate.projectItem.Total_Repair_Cost__c <
            projectItemCreate.getOVER_400(),
            true
        );

        projectItemCreate.selectedButton = 'SaveNew';
        projectItemCreate.bidWrapperList[0].bid.SOW_Description__c = 'Test';
        projectItemCreate.bidWrapperList[0].bid.Vendor__c = accVendor.Id;
        projectItemCreate.bidWrapperList[0].bid.Repair_Cost__c = 50;

        projectItemCreate.numberOfBids = 2;
        projectItemCreate.bidTotalList();

        PageReference pgRef1 = projectItemCreate.saveProjectItem();

        projectItemCreate.bidWrapperList[0].bid.SOW_Description__c = 'Test';
        projectItemCreate.bidWrapperList[0].bid.Vendor__c = accVendor.Id;
        projectItemCreate.bidWrapperList[0].bid.Repair_Cost__c = 500;
        projectItemCreate.acceptedRow = '0';
        projectItemCreate.projectItem.Over_400_Status__c = 'Over $400 Pre-work Approval';
        projectItemCreate.bidAcceptedByOwner();
        projectItemCreate.saveProjectItem();
        System.assertEquals(
            projectItemCreate.projectItem.Total_Repair_Cost__c >
            projectItemCreate.getOVER_400(),
            true
        );
        for (
            CreateProjectItemExtn.BidWrapper bidWrap : projectItemCreate.bidWrapperList
        ) {
            bidWrap.bid.Project_Item__c = projectItem.Id;
        }
        projectItemCreate.sendEmail();

        projectItemCreate.save();

        projectItemCreate.closePopupModal();
        projectItemCreate.cancel();
    }

    @isTest
    static void testMethod3() {
        System.debug('testMethod3');
        User thisUser = [
            SELECT Id, Email
            FROM User
            WHERE Id = :UserInfo.getUserId()
        ];
        User usr = [
            SELECT Id, Email
            FROM User
            WHERE LastName = 'LastNm'
            LIMIT 1
        ];

        Case cs = [SELECT Id, Property__r.Investor__c FROM Case LIMIT 1];
        Project_Item__c projectItem = [SELECT Id FROM Project_Item__c LIMIT 1];
        Account accVendor = [
            SELECT Id, Name
            FROM Account
            WHERE RecordType.Name = 'Vendor'
            LIMIT 1
        ];

        /* Contact Con =[select Id ,Name,Email,AccountId from Contact where AccountId =:accVendor.Id limit 1 ];
        Con.Is_Primary__c = true;
        update Con;  */

        PageReference pageRef = Page.CreateProjectItem;
        Test.setCurrentPage(pageRef);

        ApexPages.currentPage().getParameters().put('id', projectItem.Id);

        CreateProjectItemExtn projectItemCreate = new CreateProjectItemExtn();

        projectItemCreate.getOVER_400();
        projectItemCreate.getOver400Status();
        projectItemCreate.getMaintenanceStatus();
        projectItemCreate.getMaintenanceCategory();
        projectItemCreate.getMaintenanceSubCategory();
        projectItemCreate.getYesNo();

        projectItemCreate.saveProjectItem();

        projectItemCreate.projectItem.Maintenance_Status__c = 'Dispatched';
        projectItemCreate.checkBids();

        projectItemCreate.projectItem.Maintenance_Status__c = 'Completed';
        projectItemCreate.checkBids();

        projectItemCreate.checkPriority();

        projectItemCreate.projectItem.MaintenanceCategoryGlobal__c = 'Flooring';
        projectItemCreate.checkPriority();

        projectItemCreate.projectItem.MaintenanceCategoryGlobal__c = 'Flooring';
        projectItemCreate.projectItem.MaintenanceSubCategoryGlobal__c = 'Water Extraction';
        projectItemCreate.checkPriority();
        System.assertEquals(
            projectItemCreate.projectItem.Priority__c,
            'Critical'
        );

        projectItemCreate.projectItem.MaintenanceSubCategoryGlobal__c = 'Subfloor';
        projectItemCreate.checkPriority();
        System.assertEquals(
            projectItemCreate.projectItem.Priority__c,
            'Urgent'
        );

        projectItemCreate.projectItem.MaintenanceSubCategoryGlobal__c = 'Hardwood';
        projectItemCreate.checkPriority();
        System.assertEquals(projectItemCreate.projectItem.Priority__c, 'High');

        projectItemCreate.projectItem.MaintenanceSubCategoryGlobal__c = 'Sanding/Finishing';
        projectItemCreate.checkPriority();
        System.assertEquals(
            projectItemCreate.projectItem.Priority__c,
            'Medium'
        );

        projectItemCreate.projectItem.MaintenanceCategoryGlobal__c = 'Plumbing';
        projectItemCreate.projectItem.MaintenanceSubCategoryGlobal__c = 'Water Extraction';
        projectItemCreate.checkPriority();
        System.assertEquals(
            projectItemCreate.projectItem.Priority__c,
            'Critical'
        );

        projectItemCreate.projectItem.MaintenanceCategoryGlobal__c = 'HVAC';
        projectItemCreate.projectItem.MaintenanceSubCategoryGlobal__c = 'Furnace Installation';
        projectItemCreate.checkPriority();
        System.assertEquals(
            projectItemCreate.projectItem.Priority__c,
            'Critical'
        );

        projectItemCreate.saveProjectItem();

        projectItemCreate.projectItem.Maintenance_Status__c = 'Dispatched';
        projectItemCreate.selectedButton = 'Save';
        projectItemCreate.bidWrapperList[0].bid.SOW_Description__c = 'Test';
        projectItemCreate.bidWrapperList[0].bid.Vendor__c = accVendor.Id;

        PageReference pgRef = projectItemCreate.saveProjectItem();

        projectItemCreate.numberOfBids = 1;
        projectItemCreate.bidTotalList();

        projectItemCreate.numberOfBids = 3;
        projectItemCreate.bidTotalList();

        projectItemCreate.numberOfBids = 2;
        projectItemCreate.bidTotalList();

        projectItemCreate.acceptedRow = '0';
        projectItemCreate.bidAcceptedByOwner();

        System.assertEquals(
            projectItemCreate.projectItem.Total_Repair_Cost__c <
            projectItemCreate.getOVER_400(),
            true
        );

        projectItemCreate.selectedButton = 'SaveNew';
        projectItemCreate.bidWrapperList[0].bid.SOW_Description__c = 'Test';
        projectItemCreate.bidWrapperList[0].bid.Vendor__c = accVendor.Id;
        projectItemCreate.bidWrapperList[0].bid.Repair_Cost__c = 50;

        projectItemCreate.numberOfBids = 2;
        projectItemCreate.bidTotalList();

        PageReference pgRef1 = projectItemCreate.saveProjectItem();

        projectItemCreate.bidWrapperList[0].bid.SOW_Description__c = 'Test';
        projectItemCreate.bidWrapperList[0].bid.Vendor__c = accVendor.Id;
        projectItemCreate.bidWrapperList[0].bid.Repair_Cost__c = 500;
        projectItemCreate.acceptedRow = '0';
        projectItemCreate.projectItem.Over_400_Status__c = 'Over $400 Post-work Notification (QOL)';
        projectItemCreate.bidAcceptedByOwner();
        for (
            CreateProjectItemExtn.BidWrapper bidWrap : projectItemCreate.bidWrapperList
        ) {
            bidWrap.bid.Project_Item__c = projectItem.Id;
            bidWrap.bid.Vendor__c = accVendor.Id;
        }

        projectItemCreate.saveProjectItem();
        System.assertEquals(
            projectItemCreate.projectItem.Total_Repair_Cost__c >
            projectItemCreate.getOVER_400(),
            true
        );

        String orgId = userInfo.getOrganizationId();
        projectItemCreate.salesRepEmail =
            'testinvestorsf@tester.com' +
            orgId +
            '.org';

        list<Contact> conList = [
            SELECT Id, Name, Is_Primary__c, Email
            FROM Contact
            WHERE AccountId = :cs.Property__r.Investor__c
        ];
        conList[0].Is_Primary__c = true;
        update conList;

        projectItemCreate.toAdr = '';
        projectItemCreate.ccAdr = '';
        projectItemCreate.sendEmail();

        projectItemCreate.ccAdr = usr.Email;
        projectItemCreate.sendEmail();

        projectItemCreate.bccAdr = 'test.com';
        projectItemCreate.sendEmail();

        projectItemCreate.emailContentBefore = 'Test';
        projectItemCreate.emailContentAfter = 'Testing';
        projectItemCreate.toAdr = conList[0].Email;
        projectItemCreate.ccAdr = usr.Email;
        projectItemCreate.bccAdr = 'test@testing123.com';
        projectItemCreate.sendEmail();

        projectItemCreate.closePopupModal();
        projectItemCreate.cancel();
    }

    @isTest
    static void testMethod4() {
        System.debug('testMethod4');
        Account accInvestor = TestDataFactory.createAccount(
            'Investor acc',
            Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
                .get('Investor')
                .getRecordTypeId(),
            ''
        );
        insert accInvestor;

        Contact conInvestor = TestDataFactory.createContact(
            'Investor',
            'Tester',
            '9879654321',
            'testInvestorsf@tester.com',
            accInvestor.Id,
            Schema.SObjectType.Contact.getRecordTypeInfosByName()
                .get('Investor')
                .getRecordTypeId()
        );
        insert conInvestor;

        House__c house = TestDataFactory.createHouse(
            'A Property Name',
            '123 Test Street',
            'Apt 1',
            'Memphis',
            'TN',
            '39876',
            'US'
        );
        house.Investor__c = accInvestor.Id;
        insert house;

        Schema.DescribeFieldResult catGlobal = SObjectType.Case.fields.CategoryGlobal__c;
        List<Schema.PicklistEntry> categoryEntries = catGlobal.getPicklistValues();

        Case cs = TestDataFactory.createCase(
            Schema.SObjectType.Case.getRecordTypeInfosByName()
                .get('Maintenance')
                .getRecordTypeId(),
            'Open',
            conInvestor.Id,
            house.Id,
            'Test desc.',
            '9998887878',
            System.now(),
            false,
            System.now().addMonths(1),
            categoryEntries[0].getValue()
        );
        insert cs;

        Id maintenanceProjectRecTypeId = Schema.SObjectType.Project__c.getRecordTypeInfosByName()
            .get('Maintenance')
            .getRecordTypeId();

        Project__c project = new Project__c(
            House__c = house.Id,
            Description__c = 'Test desc.',
            Account__c = accInvestor.Id,
            Case__c = cs.Id,
            RecordTypeId = maintenanceProjectRecTypeId
        );
        project.Asking_Price__c = 18500;
        //   project.Downpayment__c = 25;
        // project.Interest_Rate__c = 4.25;
        //  project.Mortgage_Year__c = '30';
        project.Vacancy_Rate__c = 4.0;
        project.Maintenance_Rate__c = 4.0;
        project.Rent_Assumption_for_Calculations__c = 1245;
        project.Estimated_Annual_Property_Taxes__c = 1394;
        project.Estimated_Annual_HOA_Dues__c = 435;
        project.Estimated_Annual_Management_Fee_10__c = 1494;
        project.Estimated_Annual_Homeowners_Insurance__c = 754;
        project.Appreciation_Rate__c = 1.0;
        project.Lease_Closing__c = date.today() + 27;
        insert project;

        Project_Item__c projectItem = new Project_Item__c(
            Project__c = project.Id,
            Case__c = cs.Id,
            Description__c = 'Test desc.',
            Maintenance_Status__c = 'Dispatched',
            MaintenanceCategoryGlobal__c = 'Flooring',
            MaintenanceSubCategoryGlobal__c = 'Water Extraction',
            Name = 'WO-MEM-00001303-01'
        );
        insert projectItem;

        Project_Item_Bid__c bid = new Project_Item_Bid__c(
            Project_Item__c = projectItem.Id,
            SOW_Description__c = 'sow test',
            Owner_Accepted__c = true
        );
        insert bid;
        User usr = [
            SELECT Id, Email
            FROM User
            WHERE LastName = 'LastNm'
            LIMIT 1
        ];

        Account accVendor = [
            SELECT Id, Name
            FROM Account
            WHERE RecordType.Name = 'Vendor'
            LIMIT 1
        ];

        PageReference pageRef = Page.CreateProjectItem;
        Test.setCurrentPage(pageRef);

        ApexPages.currentPage().getParameters().put('id', projectItem.Id);

        CreateProjectItemExtn projectItemCreate = new CreateProjectItemExtn();

        projectItemCreate.getOVER_400();
        projectItemCreate.getOver400Status();
        projectItemCreate.getMaintenanceStatus();
        projectItemCreate.getMaintenanceCategory();
        projectItemCreate.getMaintenanceSubCategory();
        projectItemCreate.getYesNo();

        projectItemCreate.saveProjectItem();

        projectItemCreate.projectItem.Maintenance_Status__c = 'Dispatched';
        projectItemCreate.checkBids();

        projectItemCreate.projectItem.Maintenance_Status__c = 'Completed';
        projectItemCreate.checkBids();

        projectItemCreate.checkPriority();

        projectItemCreate.projectItem.MaintenanceCategoryGlobal__c = 'Flooring';
        projectItemCreate.checkPriority();

        projectItemCreate.projectItem.MaintenanceCategoryGlobal__c = 'Flooring';
        projectItemCreate.projectItem.MaintenanceSubCategoryGlobal__c = 'Water Extraction';
        projectItemCreate.checkPriority();
        System.assertEquals(
            projectItemCreate.projectItem.Priority__c,
            'Critical'
        );

        projectItemCreate.projectItem.MaintenanceSubCategoryGlobal__c = 'Subfloor';
        projectItemCreate.checkPriority();
        System.assertEquals(
            projectItemCreate.projectItem.Priority__c,
            'Urgent'
        );

        projectItemCreate.projectItem.MaintenanceSubCategoryGlobal__c = 'Hardwood';
        projectItemCreate.checkPriority();
        System.assertEquals(projectItemCreate.projectItem.Priority__c, 'High');

        projectItemCreate.projectItem.MaintenanceSubCategoryGlobal__c = 'Sanding/Finishing';
        projectItemCreate.checkPriority();
        System.assertEquals(
            projectItemCreate.projectItem.Priority__c,
            'Medium'
        );

        projectItemCreate.projectItem.MaintenanceCategoryGlobal__c = 'Plumbing';
        projectItemCreate.projectItem.MaintenanceSubCategoryGlobal__c = 'Water Extraction';
        projectItemCreate.checkPriority();
        System.assertEquals(
            projectItemCreate.projectItem.Priority__c,
            'Critical'
        );

        projectItemCreate.projectItem.MaintenanceCategoryGlobal__c = 'HVAC';
        projectItemCreate.projectItem.MaintenanceSubCategoryGlobal__c = 'Furnace Installation';
        projectItemCreate.checkPriority();
        System.assertEquals(
            projectItemCreate.projectItem.Priority__c,
            'Critical'
        );

        projectItemCreate.saveProjectItem();

        projectItemCreate.projectItem.Maintenance_Status__c = 'Dispatched';
        projectItemCreate.selectedButton = 'Save';
        projectItemCreate.bidWrapperList[0].bid.SOW_Description__c = 'Test';
        projectItemCreate.bidWrapperList[0].bid.Vendor__c = accVendor.Id;

        PageReference pgRef = projectItemCreate.saveProjectItem();

        projectItemCreate.numberOfBids = 1;
        projectItemCreate.bidTotalList();

        projectItemCreate.numberOfBids = 3;
        projectItemCreate.bidTotalList();

        projectItemCreate.numberOfBids = 2;
        projectItemCreate.bidTotalList();

        projectItemCreate.acceptedRow = '0';
        projectItemCreate.bidAcceptedByOwner();

        System.assertEquals(
            projectItemCreate.projectItem.Total_Repair_Cost__c <
            projectItemCreate.getOVER_400(),
            true
        );

        projectItemCreate.selectedButton = 'SaveNew';
        projectItemCreate.bidWrapperList[0].bid.SOW_Description__c = 'Test';
        projectItemCreate.bidWrapperList[0].bid.Vendor__c = accVendor.Id;
        projectItemCreate.bidWrapperList[0].bid.Repair_Cost__c = 50;

        projectItemCreate.numberOfBids = 2;
        projectItemCreate.bidTotalList();

        PageReference pgRef1 = projectItemCreate.saveProjectItem();

        projectItemCreate.bidWrapperList[0].bid.SOW_Description__c = 'Test';
        projectItemCreate.bidWrapperList[0].bid.Vendor__c = accVendor.Id;
        projectItemCreate.bidWrapperList[0].bid.Repair_Cost__c = 500;
        projectItemCreate.acceptedRow = '0';
        projectItemCreate.projectItem.Over_400_Status__c = 'Over $400 Post-work Notification (QOL)';
        projectItemCreate.bidAcceptedByOwner();
        projectItemCreate.saveProjectItem();
        System.assertEquals(
            projectItemCreate.projectItem.Total_Repair_Cost__c >
            projectItemCreate.getOVER_400(),
            true
        );

        for (
            CreateProjectItemExtn.BidWrapper bidWrap : projectItemCreate.bidWrapperList
        ) {
            bidWrap.bid.Project_Item__c = projectItem.Id;
        }

        projectItemCreate.emailContentBefore = 'Test';
        projectItemCreate.emailContentAfter = 'Testing';
        projectItemCreate.toAdr = 'testInvestorsf@tester.com';
        projectItemCreate.ccAdr = usr.Email;
        projectItemCreate.bccAdr = 'test980@gmail.com';
        projectItemCreate.sendEmail();
        new CreateProjectItemExtn.ContentVersionWrapper(null, false);

        projectItemCreate.closePopupModal();
        projectItemCreate.cancel();
    }

    @isTest
    static void testMethod5() {
        System.debug('testMethod5');
        Account accInvestor = TestDataFactory.createAccount(
            'Investor acc',
            Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
                .get('Investor')
                .getRecordTypeId(),
            ''
        );
        insert accInvestor;

        Contact conInvestor = TestDataFactory.createContact(
            'Investor',
            'Tester',
            '9879654321',
            'testInvestorsf@tester.com',
            accInvestor.Id,
            Schema.SObjectType.Contact.getRecordTypeInfosByName()
                .get('Investor')
                .getRecordTypeId()
        );
        insert conInvestor;

        House__c house = TestDataFactory.createHouse(
            'A Place',
            '555 House Ave',
            'Unit 19',
            'Memphis',
            'TN',
            '39876',
            'US'
        );
        house.Investor__c = accInvestor.Id;
        insert house;

        Schema.DescribeFieldResult catGlobal = SObjectType.Case.fields.CategoryGlobal__c;
        List<Schema.PicklistEntry> categoryEntries = catGlobal.getPicklistValues();

        Case cs = TestDataFactory.createCase(
            Schema.SObjectType.Case.getRecordTypeInfosByName()
                .get('Maintenance')
                .getRecordTypeId(),
            'Open',
            conInvestor.Id,
            house.Id,
            'Test desc.',
            '9998887878',
            System.now(),
            false,
            System.now().addMonths(1),
            categoryEntries[0].getValue()
        );
        insert cs;

        Id renovationProjectRecTypeId = Schema.SObjectType.Project__c.getRecordTypeInfosByName()
            .get('Renovation')
            .getRecordTypeId();

        Project__c project = new Project__c(
            House__c = house.Id,
            Description__c = 'Test desc.',
            Account__c = accInvestor.Id,
            Case__c = cs.Id,
            RecordTypeId = renovationProjectRecTypeId
        );
        project.Asking_Price__c = 18500;
        //   project.Downpayment__c = 25;
        // project.Interest_Rate__c = 4.25;
        //  project.Mortgage_Year__c = '30';
        project.Vacancy_Rate__c = 4.0;
        project.Maintenance_Rate__c = 4.0;
        project.Rent_Assumption_for_Calculations__c = 1245;
        project.Estimated_Annual_Property_Taxes__c = 1394;
        project.Estimated_Annual_HOA_Dues__c = 435;
        project.Estimated_Annual_Management_Fee_10__c = 1494;
        project.Estimated_Annual_Homeowners_Insurance__c = 754;
        project.Appreciation_Rate__c = 1.0;
        project.Lease_Closing__c = date.today() + 30;
        project.Pay_Account__c = 'New WME';
        insert project;

        Project_Item__c projectItem = new Project_Item__c(
            Project__c = project.Id,
            Case__c = cs.Id,
            Description__c = 'Test desc.',
            Maintenance_Status__c = 'Dispatched',
            MaintenanceCategoryGlobal__c = 'Flooring',
            MaintenanceSubCategoryGlobal__c = 'Water Extraction',
            Name = 'WO-MEM-00001303-01'
        );
        insert projectItem;

        Project_Item_Bid__c bid = new Project_Item_Bid__c(
            Project_Item__c = projectItem.Id,
            SOW_Description__c = 'sow test',
            Owner_Accepted__c = true
        );
        insert bid;
        User usr = [
            SELECT Id, Email
            FROM User
            WHERE LastName = 'LastNm'
            LIMIT 1
        ];

        Account accVendor = [
            SELECT Id, Name
            FROM Account
            WHERE RecordType.Name = 'Vendor'
            LIMIT 1
        ];

        PageReference pageRef = Page.CreateProjectItem;
        Test.setCurrentPage(pageRef);

        ApexPages.currentPage().getParameters().put('id', projectItem.Id);

        CreateProjectItemExtn projectItemCreate = new CreateProjectItemExtn();

        projectItemCreate.getOVER_400();
        projectItemCreate.getOver400Status();
        projectItemCreate.getMaintenanceStatus();
        projectItemCreate.getMaintenanceCategory();
        projectItemCreate.getMaintenanceSubCategory();
        projectItemCreate.getYesNo();

        projectItemCreate.saveProjectItem();

        projectItemCreate.projectItem.Maintenance_Status__c = 'Dispatched';
        projectItemCreate.checkBids();

        projectItemCreate.projectItem.Maintenance_Status__c = 'Completed';
        projectItemCreate.checkBids();

        projectItemCreate.checkPriority();

        projectItemCreate.projectItem.MaintenanceCategoryGlobal__c = 'Flooring';
        projectItemCreate.checkPriority();

        projectItemCreate.projectItem.MaintenanceCategoryGlobal__c = 'Flooring';
        projectItemCreate.projectItem.MaintenanceSubCategoryGlobal__c = 'Water Extraction';
        projectItemCreate.checkPriority();
        System.assertEquals(
            projectItemCreate.projectItem.Priority__c,
            'Critical'
        );

        projectItemCreate.projectItem.MaintenanceSubCategoryGlobal__c = 'Subfloor';
        projectItemCreate.checkPriority();
        System.assertEquals(
            projectItemCreate.projectItem.Priority__c,
            'Urgent'
        );

        projectItemCreate.projectItem.MaintenanceSubCategoryGlobal__c = 'Hardwood';
        projectItemCreate.checkPriority();
        System.assertEquals(projectItemCreate.projectItem.Priority__c, 'High');

        projectItemCreate.projectItem.MaintenanceSubCategoryGlobal__c = 'Sanding/Finishing';
        projectItemCreate.checkPriority();
        System.assertEquals(
            projectItemCreate.projectItem.Priority__c,
            'Medium'
        );

        projectItemCreate.projectItem.MaintenanceCategoryGlobal__c = 'Plumbing';
        projectItemCreate.projectItem.MaintenanceSubCategoryGlobal__c = 'Water Extraction';
        projectItemCreate.checkPriority();
        System.assertEquals(
            projectItemCreate.projectItem.Priority__c,
            'Critical'
        );

        projectItemCreate.projectItem.MaintenanceCategoryGlobal__c = 'HVAC';
        projectItemCreate.projectItem.MaintenanceSubCategoryGlobal__c = 'Furnace Installation';
        projectItemCreate.checkPriority();
        System.assertEquals(
            projectItemCreate.projectItem.Priority__c,
            'Critical'
        );

        projectItemCreate.saveProjectItem();

        projectItemCreate.projectItem.Maintenance_Status__c = 'Dispatched';
        projectItemCreate.selectedButton = 'Save';
        projectItemCreate.bidWrapperList[0].bid.SOW_Description__c = 'Test';
        projectItemCreate.bidWrapperList[0].bid.Vendor__c = accVendor.Id;

        PageReference pgRef = projectItemCreate.saveProjectItem();

        projectItemCreate.numberOfBids = 1;
        projectItemCreate.bidTotalList();

        projectItemCreate.numberOfBids = 3;
        projectItemCreate.bidTotalList();

        projectItemCreate.numberOfBids = 2;
        projectItemCreate.bidTotalList();

        projectItemCreate.acceptedRow = '0';
        projectItemCreate.bidAcceptedByOwner();

        System.assertEquals(
            projectItemCreate.projectItem.Total_Repair_Cost__c <
            projectItemCreate.getOVER_400(),
            true
        );

        projectItemCreate.selectedButton = 'SaveNew';
        projectItemCreate.bidWrapperList[0].bid.SOW_Description__c = 'Test';
        projectItemCreate.bidWrapperList[0].bid.Vendor__c = accVendor.Id;
        projectItemCreate.bidWrapperList[0].bid.Repair_Cost__c = 50;

        projectItemCreate.numberOfBids = 2;
        projectItemCreate.bidTotalList();

        PageReference pgRef1 = projectItemCreate.saveProjectItem();

        projectItemCreate.bidWrapperList[0].bid.SOW_Description__c = 'Test';
        projectItemCreate.bidWrapperList[0].bid.Vendor__c = accVendor.Id;
        projectItemCreate.bidWrapperList[0].bid.Repair_Cost__c = 500;
        projectItemCreate.acceptedRow = '0';
        projectItemCreate.projectItem.Over_400_Status__c = 'Over $400 Post-work Notification (QOL)';
        projectItemCreate.bidAcceptedByOwner();
        projectItemCreate.saveProjectItem();
        System.assertEquals(
            projectItemCreate.projectItem.Total_Repair_Cost__c >
            projectItemCreate.getOVER_400(),
            true
        );

        for (
            CreateProjectItemExtn.BidWrapper bidWrap : projectItemCreate.bidWrapperList
        ) {
            bidWrap.bid.Project_Item__c = projectItem.Id;
        }

        projectItemCreate.emailContentBefore = 'Test';
        projectItemCreate.emailContentAfter = 'Testing';
        projectItemCreate.toAdr = 'testInvestorsf@tester.com';
        projectItemCreate.ccAdr = usr.Email;
        projectItemCreate.bccAdr = 'test980@gmail.com';
        projectItemCreate.sendEmail();
        new CreateProjectItemExtn.ContentVersionWrapper(null, false);

        projectItemCreate.closePopupModal();
        projectItemCreate.cancel();
    }
}