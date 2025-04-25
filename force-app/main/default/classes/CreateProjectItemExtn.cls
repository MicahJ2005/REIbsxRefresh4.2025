/**
Name        : CreateProjectItemExtn 
Date        : 
Author      : Shweta Fulara(Cmentor)
Description : Apex class for CreateProjectItem Page.
Modification: June 26,2019 SalesRep Email should not be madatory
**/
public without sharing class CreateProjectItemExtn {
    //Variable Declaration
    public Integer getOVER_400() {
        return UtilVariables.INT_OVER_400;
    }

    public Boolean showPopup { get; set; }
    public String emailContentBefore { get; set; }
    public String emailContentAfter { get; set; }
    public String hasMultipleBids { get; set; }
    public Integer numberOfBids { get; set; }
    public String acceptedRow { get; set; }
    public String selectedButton { get; set; }
    public String workOrderTag { get; set; }
    public Decimal totalRepairCost { get; set; }
    public String toAdr { get; set; }
    public String ccAdr { get; set; }
    public String bccAdr { get; set; }
    public String salesRepEmail { get; set; }
    public Date lastLeaseCloseDate { get; private set; }
    public String lastLeaseProjectType { get; private set; }
    public Boolean first30days { get; set; }

    public Case cs { get; set; }
    public Project__c project { get; set; }
    public Project_Item__c projectItem { get; set; }
    public List<BidWrapper> bidWrapperList { get; set; }
    public transient List<Case> caseHistoryList { get; set; }

    //document variables
    public String error { get; set; }
    public String selectedDocumentFolder { public get; public set; }
    public List<EmailAttachmentWrapper> emailAttachmentListWrapper { get; set; }
    public String rowIndexAttach { get; set; }
    public String newFileId { get; set; }
    private Map<Id, ContentVersion> allFiles;
    public List<DocumentWrapper> docWrapList { get; set; }

    String houseStreetAdr;
    String houseAdr;

    List<Project__c> projectLastLeaseList;
    List<Project_Item_Bid__c> bidsToDelete;
    String num = null;
    Integer numLength;

    public CreateProjectItemExtn() {
        Id recordId = ApexPages.currentPage().getParameters().get('id');

        bidsToDelete = new List<Project_Item_Bid__c>();
        projectLastLeaseList = new List<Project__c>();
        lastLeaseCloseDate = null;
        lastLeaseProjectType = '';
        first30days = false;
        toAdr = '';
        ccAdr = '';
        bccAdr = '';
        salesRepEmail = '';
        workOrderTag = '';
        houseAdr = '';
        showPopup = false;
        acceptedRow = '';
        numberOfBids = 1;
        totalRepairCost = 0;
        hasMultipleBids = 'No';
        caseHistoryList = new List<Case>();
        bidWrapperList = new List<BidWrapper>();
        docWrapList = new List<DocumentWrapper>();

        Set<Id> cdlIds = new Set<Id>();
        for (ContentDocumentLink cdl : [
            SELECT ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :recordId
        ]) {
            cdlIds.add(cdl.ContentDocumentId);
            system.debug('cdlIds :: ' + cdlIds);
        }
        allFiles = new Map<Id, ContentVersion>(
            [
                SELECT id, Title
                FROM ContentVersion
                WHERE ContentDocumentId IN :cdlIds
                ORDER BY Title ASC
            ]
        );
        for (ContentVersion cv : allFiles.values()) {
            docWrapList.add(new DocumentWrapper(false, cv.Title, cv.Id));
            system.debug('docWrapList :: ' + docWrapList);
        }
        emailAttachmentListWrapper = new List<EmailAttachmentWrapper>();

        Id maintenanceProjectItemRecTypeId = Schema.SObjectType.Project_Item__c.getRecordTypeInfosByName()
            .get('Maintenance')
            .getRecordTypeId();

        if (recordId.getSObjectType().getDescribe().getName() == 'Case') {
            BidWrapper bidWrap = new BidWrapper();
            bidWrap.bid = new Project_Item_Bid__c(Bid_Fee__c = false);
            bidWrapperList = new List<BidWrapper>{ bidWrap };
            cs = [
                SELECT
                    Id,
                    ContactId,
                    Contact_Information__c,
                    Status,
                    Renovation_Warranty_Stage_Indicator__c,
                    Owner_Warranty_Stage_Indicator__c,
                    Description,
                    FU_Phone__c,
                    Property__c,
                    Property__r.Name,
                    Property__r.Market__c,
                    Property__r.Investor__c,
                    Property__r.Street_Address__c,
                    Property__r.Street_Address_Line_2__c,
                    Property__r.City__c,
                    Property__r.State__c,
                    Property__r.Zip_Code__c,
                    Property__r.Country__c,
                    Property__r.Customer_Service_Assignment_Lookup__c,
                    Property__r.Investor__r.Customer_Service_Assignment__c,
                    Property__r.Investor__r.Customer_Service_Assignment__r.Email,
                    CaseNumber,
                    CategoryGlobal__c,
                    AccountId,
                    ClosedDate,
                    OwnerId,
                    CreatedDate,
                    User__c
                FROM Case
                WHERE Id = :recordId
            ];

            caseHistoryList = [
                SELECT
                    Id,
                    Status,
                    Description,
                    Property__c,
                    Property__r.Market__c,
                    CaseNumber,
                    CategoryGlobal__c,
                    AccountId,
                    ClosedDate,
                    Vendor_Name__c,
                    Vendor_Date_Closed__c,
                    CreatedDate
                FROM Case
                WHERE
                    Property__c = :cs.Property__c
                    AND CreatedDate = LAST_N_DAYS:90
            ];

            projectItem = new Project_Item__c(
                Case__c = cs.Id,
                Contact__c = cs.ContactId,
                Total_Repair_Cost__c = 0,
                RecordTypeId = maintenanceProjectItemRecTypeId,
                Description__c = cs.Description,
                MaintenanceCategoryGlobal__c = cs.CategoryGlobal__c
            );

            List<Project__c> projectList = [
                SELECT
                    Id,
                    Maint_After_Move_In_Initial__c,
                    Maint_After_Move_In__c,
                    Last_Lease_Closing_Date__c,
                    House__c,
                    House__r.Name,
                    House__r.Market__c
                FROM Project__c
                WHERE Case__c = :cs.Id AND RecordType.Name = 'Maintenance'
            ];
            List<Project_Item__c> projectItemLastList = [
                SELECT Id, Name
                FROM Project_Item__c
                WHERE Case__c = :cs.Id AND RecordType.Name = 'Maintenance'
                ORDER BY Id DESC
                LIMIT 1
            ];

            if (!projectItemLastList.isEmpty()) {
                String name = projectItemLastList[0].Name;
                if (
                    name.contains(
                        'WO-' + cs.Property__r.Market__c + '-' + cs.CaseNumber
                    )
                ) {
                    name = name.substringAfterLast('-');
                    num = String.valueOf(Integer.valueOf(name) + 1);
                } else {
                    num = '01';
                }
                System.debug('num-----' + num);
            } else {
                num = '01';
                System.debug('num-----' + num);
            }

            numLength = num.length();
            num = numLength == 1 ? '0' + num : num;

            projectLastLeaseList = [
                SELECT
                    Id,
                    Maint_After_Move_In__c,
                    Maint_After_Move_In_Initial__c,
                    RecordType.Name,
                    Last_Lease_Closing_Date__c
                FROM Project__c
                WHERE Lease_Closing__c != NULL AND House__c = :cs.Property__c
                ORDER BY Lease_Closing__c DESC
                LIMIT 1
            ];

            System.debug(
                '### projectLastLeaseList-----' + projectLastLeaseList
            );

            if (!projectList.isEmpty()) {
                project = projectList[0];
                projectItem.Project__c = project.Id;
                projectItem.Name =
                    'WO-' +
                    project.House__r.Market__c +
                    '-' +
                    cs.CaseNumber +
                    '-' +
                    num;
                if (!projectLastLeaseList.isEmpty()) {
                    lastLeaseCloseDate = projectLastLeaseList[0]
                        .Last_Lease_Closing_Date__c;
                    lastLeaseProjectType = projectLastLeaseList[0]
                        .RecordType.Name;
                    if (lastLeaseCloseDate != null) {
                        Integer leaseclosingDays = lastLeaseCloseDate.daysBetween(
                            System.today()
                        );
                        System.debug('leaseclosingDays----' + leaseclosingDays);
                        System.debug(
                            'lastLeaseProjectType----' + lastLeaseProjectType
                        );
                        if (lastLeaseProjectType == 'Move Out') {
                            workOrderTag = 'N/A';
                        } else if (lastLeaseProjectType == 'Renovation') {
                            workOrderTag = (leaseclosingDays == 0 ||
                                leaseclosingDays > 365)
                                ? 'N/A'
                                : (leaseclosingDays > 0 &&
                                      leaseclosingDays <= 90)
                                      ? '1-90'
                                      : '91-365';
                        }
                        if (leaseclosingDays <= 30) {
                            first30days = true;
                        }
                    }
                }
            } else {
                Id maintenanceProjectRecTypeId = Schema.SObjectType.Project__c.getRecordTypeInfosByName()
                    .get('Maintenance')
                    .getRecordTypeId();

                project = new Project__c(
                    House__c = cs.Property__c,
                    Description__c = cs.Description,
                    Account__c = cs.AccountId,
                    Case__c = cs.Id,
                    RecordTypeId = maintenanceProjectRecTypeId
                );
                System.debug('projectLastLeaseList: ' + projectItemLastList);
                if (!projectLastLeaseList.isEmpty()) {
                    lastLeaseCloseDate = projectLastLeaseList[0]
                        .Last_Lease_Closing_Date__c;
                    lastLeaseProjectType = projectLastLeaseList[0]
                        .RecordType.Name;
                    if (lastLeaseCloseDate != null) {
                        Integer leaseclosingDays = lastLeaseCloseDate.daysBetween(
                            System.today()
                        );
                        System.debug('leaseclosingDays----' + leaseclosingDays);
                        if (lastLeaseProjectType == 'Move Out') {
                            workOrderTag = 'N/A';
                        } else if (lastLeaseProjectType == 'Renovation') {
                            workOrderTag = (leaseclosingDays == 0 ||
                                leaseclosingDays > 365)
                                ? 'N/A'
                                : (leaseclosingDays > 0 &&
                                      leaseclosingDays <= 90)
                                      ? '1-90'
                                      : '91-365';
                        }
                        if (leaseclosingDays <= 30) {
                            first30days = true;
                        }
                    }
                }
                if (cs.ClosedDate != null) {
                    project.Date_Closed__c = cs.ClosedDate.date();
                }
                if (cs.CreatedDate != null) {
                    project.Date_Created__c = cs.CreatedDate.date();
                }
                projectItem.Name =
                    'WO-' +
                    cs.Property__r.Market__c +
                    '-' +
                    cs.CaseNumber +
                    '-' +
                    num;
            }
        } else {
            projectItem = [
                SELECT
                    Id,
                    Contact__c,
                    Closing_Date__c,
                    Description__c,
                    Completed_Date__c,
                    Vendor_Start_Date__c,
                    MaintenanceDispatch_Date__c,
                    Case__c,
                    Name,
                    Project__c,
                    Case__r.Property__c,
                    Case__r.Property__r.Investor__c,
                    Priority__c,
                    Maintenance_Status__c,
                    MaintenanceCategoryGlobal__c,
                    MaintenanceSubCategoryGlobal__c,
                    Vendor_Acct__c,
                    Total_Repair_Cost__c,
                    Over_400_Description__c,
                    Notes__c,
                    CreatedDate,
                    Over_400_Status__c,
                    Maintenance_Not_Fixing_Reason__c,
                    Maintenance_Standby_Reason__c,
                    Maintenance_Unsatisfied_Reason__c,
                    Last_Lease_Closing_Date__c,
                    Other_Reason__c,
                    Is_Active_Dispatched__c,
                    Owner_Warranty_Stage__c,
                    Owner_Warranty_Stage_Indicator__c,
                    Renovation_Warranty_Stage__c,
                    Renovation_Warranty_Stage_Indicator__c
                FROM Project_Item__c
                WHERE Id = :recordId
            ];
            if (projectItem.Total_Repair_Cost__c == null) {
                projectItem.Total_Repair_Cost__c = 0;
            }

            numberOfBids = 1;

            Integer i = 0;
            for (Project_Item_Bid__c bid : [
                SELECT
                    Id,
                    Name,
                    Owner_Accepted__c,
                    Vendor__c,
                    Repair_Cost__c,
                    Bid_Fee__c,
                    Amount__c,
                    SOW_Description__c,
                    Markup__c,
                    Markup_Amount__c
                FROM Project_Item_Bid__c
                WHERE Project_Item__c = :projectItem.Id
            ]) {
                if (i > 0) {
                    numberOfBids++;
                }
                if (bid.Owner_Accepted__c) {
                    acceptedRow = String.valueOf(i);
                }

                BidWrapper bidWrap = new BidWrapper();
                bidWrap.bid = bid;
                bidWrapperList.add(bidWrap);

                i++;
            }

            if (numberOfBids > 1) {
                hasMultipleBids = 'Yes';
            }

            cs = [
                SELECT
                    Id,
                    ContactId,
                    Status,
                    Contact_Information__c,
                    Description,
                    FU_Phone__c,
                    Renovation_Warranty_Stage_Indicator__c,
                    Owner_Warranty_Stage_Indicator__c,
                    Property__c,
                    Property__r.Name,
                    Property__r.Market__c,
                    Property__r.Investor__c,
                    Property__r.Street_Address__c,
                    Property__r.Street_Address_Line_2__c,
                    Property__r.City__c,
                    Property__r.State__c,
                    Property__r.Zip_Code__c,
                    Property__r.Country__c,
                    Property__r.Customer_Service_Assignment_Lookup__c,
                    Property__r.Investor__r.Customer_Service_Assignment__c,
                    Property__r.Investor__r.Customer_Service_Assignment__r.Email,
                    CaseNumber,
                    CategoryGlobal__c,
                    AccountId,
                    ClosedDate,
                    CreatedDate,
                    OwnerId
                FROM Case
                WHERE Id = :projectItem.Case__c
            ];

            caseHistoryList = [
                SELECT
                    Id,
                    Status,
                    Description,
                    Property__c,
                    Property__r.Market__c,
                    CaseNumber,
                    CategoryGlobal__c,
                    AccountId,
                    ClosedDate,
                    Vendor_Name__c,
                    Vendor_Date_Closed__c,
                    CreatedDate
                FROM Case
                WHERE
                    Property__c = :projectItem.Case__r.Property__c
                    AND CreatedDate = LAST_N_DAYS:90
            ];

            List<Project__c> projectList = [
                SELECT
                    Id,
                    Maint_After_Move_In_Initial__c,
                    Maint_After_Move_In__c,
                    Last_Lease_Closing_Date__c,
                    House__c,
                    House__r.Name,
                    House__r.Market__c
                FROM Project__c
                WHERE Id = :projectItem.Project__c
            ];

            if (!projectList.isEmpty()) {
                project = projectList[0];
            }

            projectLastLeaseList = [
                SELECT
                    Id,
                    RecordType.Name,
                    Maint_After_Move_In_Initial__c,
                    Maint_After_Move_In__c,
                    Last_Lease_Closing_Date__c
                FROM Project__c
                WHERE Lease_Closing__c != NULL AND House__c = :cs.Property__c
                ORDER BY Lease_Closing__c DESC
                LIMIT 1
            ];
            if (!projectLastLeaseList.isEmpty()) {
                lastLeaseCloseDate = projectLastLeaseList[0]
                    .Last_Lease_Closing_Date__c;
                lastLeaseProjectType = projectLastLeaseList[0].RecordType.Name;
                if (lastLeaseCloseDate != null) {
                    Integer leaseclosingDays = lastLeaseCloseDate.daysBetween(
                        Date.valueOf(projectItem.CreatedDate)
                    );
                    System.debug('leaseclosingDays----' + leaseclosingDays);
                    if (lastLeaseProjectType == 'Move Out') {
                        workOrderTag = 'N/A';
                    } else if (lastLeaseProjectType == 'Renovation') {
                        workOrderTag = (leaseclosingDays == 0 ||
                            leaseclosingDays > 365)
                            ? 'N/A'
                            : (leaseclosingDays > 0 &&
                                  leaseclosingDays <= 90)
                                  ? '1-90'
                                  : '91-365';
                    }
                    if (leaseclosingDays <= 30) {
                        first30days = true;
                    }
                }
            }
        }

        if (String.isNotBlank(cs.Property__r.Street_Address__c)) {
            houseAdr = cs.Property__r.Street_Address__c;
            // houseStreetAdr = cs.Property__r.Street_Address__c;
            houseStreetAdr =
                cs.Property__r.Street_Address__c +
                ', ' +
                cs.Property__r.City__c +
                ', ' +
                cs.Property__r.State__c +
                ' ' +
                cs.Property__r.Zip_Code__c;
        }
        if (String.isNotBlank(cs.Property__r.Street_Address_Line_2__c)) {
            houseAdr += ', ' + cs.Property__r.Street_Address_Line_2__c;
        }
        if (String.isNotBlank(cs.Property__r.City__c)) {
            houseAdr += ', ' + cs.Property__r.City__c;
        }
        if (String.isNotBlank(cs.Property__r.State__c)) {
            houseAdr += ', ' + cs.Property__r.State__c;
        }
        if (String.isNotBlank(cs.Property__r.Zip_Code__c)) {
            houseAdr += ' ' + cs.Property__r.Zip_Code__c;
        }
        if (String.isNotBlank(cs.Property__r.Country__c)) {
            houseAdr += ' ' + cs.Property__r.Country__c;
        }
    }

    public PageReference closePopupModal() {
        showPopup = false;
        return null;
    }

    public PageReference checkBids() {
        if (projectItem.Maintenance_Status__c == 'Active Dispatched') {
            projectItem.MaintenanceDispatch_Date__c = System.today();
        }
        if (projectItem.Maintenance_Status__c == 'Completed') {
            projectItem.Completed_Date__c = System.today();
        }
        return null;
    }

    public PageReference checkPriority() {
        if (
            projectItem.MaintenanceCategoryGlobal__c == '' &&
            projectItem.MaintenanceSubCategoryGlobal__c == ''
        ) {
            projectItem.Priority__c = '';
        } else if (projectItem.MaintenanceSubCategoryGlobal__c == '') {
            projectItem.Priority__c = '';
        } else if (
            (projectItem.MaintenanceCategoryGlobal__c == 'Flooring' &&
            projectItem.MaintenanceSubCategoryGlobal__c ==
            'Water Extraction') ||
            (projectItem.MaintenanceCategoryGlobal__c == 'Plumbing' &&
            (projectItem.MaintenanceSubCategoryGlobal__c == 'Gas Leak' ||
            projectItem.MaintenanceSubCategoryGlobal__c == 'Hot Water Heater' ||
            projectItem.MaintenanceSubCategoryGlobal__c ==
            'Interior Leak/Pipe Burst' ||
            projectItem.MaintenanceSubCategoryGlobal__c ==
            'Water Extraction')) ||
            (projectItem.MaintenanceCategoryGlobal__c == 'Electrical' &&
            projectItem.MaintenanceSubCategoryGlobal__c == 'Meter/Lines') ||
            (projectItem.MaintenanceCategoryGlobal__c == 'Exterior General' &&
            projectItem.MaintenanceSubCategoryGlobal__c == 'Doors') ||
            (projectItem.MaintenanceCategoryGlobal__c == 'HVAC' &&
            (projectItem.MaintenanceSubCategoryGlobal__c == 'Heat Service' ||
            projectItem.MaintenanceSubCategoryGlobal__c ==
            'Condenser Installation' ||
            projectItem.MaintenanceSubCategoryGlobal__c ==
            'Furnace Installation')) ||
            (projectItem.MaintenanceCategoryGlobal__c == 'Roof' &&
            (projectItem.MaintenanceSubCategoryGlobal__c == 'Leak' ||
            projectItem.MaintenanceSubCategoryGlobal__c == 'Replacement'))
        ) {
            projectItem.Priority__c = 'Critical';
        } else if (
            (projectItem.MaintenanceCategoryGlobal__c == 'Flooring' &&            projectItem.MaintenanceSubCategoryGlobal__c == 'Subfloor') ||            (projectItem.MaintenanceCategoryGlobal__c == 'Plumbing' &&            (projectItem.MaintenanceSubCategoryGlobal__c ==            'Exterior Leak/Pipe Burst' ||            projectItem.MaintenanceSubCategoryGlobal__c == 'HWH Replacement' ||            projectItem.MaintenanceSubCategoryGlobal__c == 'Toilet Stoppage' ||            projectItem.MaintenanceSubCategoryGlobal__c ==            'Sewage Stoppage')) ||            (projectItem.MaintenanceCategoryGlobal__c == 'Electrical' &&            projectItem.MaintenanceSubCategoryGlobal__c == 'Breaker Pannel') ||            (projectItem.MaintenanceCategoryGlobal__c == 'Appliance' &&            projectItem.MaintenanceSubCategoryGlobal__c == 'Repair') ||            (projectItem.MaintenanceCategoryGlobal__c == 'Exterior General' &&            (projectItem.MaintenanceSubCategoryGlobal__c == 'Brick Repair' ||            projectItem.MaintenanceSubCategoryGlobal__c == 'Decking' ||            projectItem.MaintenanceSubCategoryGlobal__c ==            'Foundation Repair' ||            projectItem.MaintenanceSubCategoryGlobal__c == 'Siding Repair' ||            projectItem.MaintenanceSubCategoryGlobal__c == 'Theft/Break-In')) ||            (projectItem.MaintenanceCategoryGlobal__c == 'Interior General' &&            (projectItem.MaintenanceSubCategoryGlobal__c == 'Insulation' ||            projectItem.MaintenanceSubCategoryGlobal__c == 'Stairs' ||            projectItem.MaintenanceSubCategoryGlobal__c == 'Windows')) ||            (projectItem.MaintenanceCategoryGlobal__c == 'Garage' &&            projectItem.MaintenanceSubCategoryGlobal__c == 'Garage Motor') ||            (projectItem.MaintenanceCategoryGlobal__c == 'HVAC' &&            (projectItem.MaintenanceSubCategoryGlobal__c == 'AC Leak' ||            projectItem.MaintenanceSubCategoryGlobal__c == 'AC Service' ||            projectItem.MaintenanceSubCategoryGlobal__c ==            'Cage Installation' ||            projectItem.MaintenanceSubCategoryGlobal__c == 'Cage Repair' ||            projectItem.MaintenanceSubCategoryGlobal__c == 'Theft/Break-In')) ||            (projectItem.MaintenanceCategoryGlobal__c == 'Roof' &&            (projectItem.MaintenanceSubCategoryGlobal__c == 'Shingles' ||            projectItem.MaintenanceSubCategoryGlobal__c == 'Debris Removal')) ||            (projectItem.MaintenanceCategoryGlobal__c == 'Chimney' &&            projectItem.MaintenanceSubCategoryGlobal__c == 'Leak') ||            (projectItem.MaintenanceCategoryGlobal__c == 'Landscaping' &&            projectItem.MaintenanceSubCategoryGlobal__c == 'Grading/Drains') ||            (projectItem.MaintenanceCategoryGlobal__c == 'Locks' &&            projectItem.MaintenanceSubCategoryGlobal__c == 'Security Door') ||            (projectItem.MaintenanceCategoryGlobal__c == 'Foundation' &&            (projectItem.MaintenanceSubCategoryGlobal__c == 'Wall Crack' ||            projectItem.MaintenanceSubCategoryGlobal__c == 'Water Intrusion'))
        ) {
            projectItem.Priority__c = 'Urgent';
        } else if (
            (projectItem.MaintenanceCategoryGlobal__c == 'Flooring' &&
            (projectItem.MaintenanceSubCategoryGlobal__c ==
            'Carpet Replacement' ||
            projectItem.MaintenanceSubCategoryGlobal__c == 'Hardwood' ||
            projectItem.MaintenanceSubCategoryGlobal__c == 'Repair' ||
            projectItem.MaintenanceSubCategoryGlobal__c == 'Tile' ||
            projectItem.MaintenanceSubCategoryGlobal__c == 'Vinyl Plank')) ||
            (projectItem.MaintenanceCategoryGlobal__c == 'Plumbing' &&
            (projectItem.MaintenanceSubCategoryGlobal__c == 'Sink Stoppage' ||
            projectItem.MaintenanceSubCategoryGlobal__c == 'Toilet Running' ||
            projectItem.MaintenanceSubCategoryGlobal__c == 'Tub Stoppage' ||
            projectItem.MaintenanceSubCategoryGlobal__c == 'Water Pressure')) ||
            (projectItem.MaintenanceCategoryGlobal__c == 'Electrical' &&
            projectItem.MaintenanceSubCategoryGlobal__c == 'Exhaust Fan') ||
            (projectItem.MaintenanceCategoryGlobal__c == 'Appliance' &&
            projectItem.MaintenanceSubCategoryGlobal__c == 'Install') ||
            (projectItem.MaintenanceCategoryGlobal__c == 'Bathtub' &&
            (projectItem.MaintenanceSubCategoryGlobal__c == 'Bathtub Repair' ||
            projectItem.MaintenanceSubCategoryGlobal__c ==
            'Bathtub Installation')) ||
            (projectItem.MaintenanceCategoryGlobal__c == 'Exterior General' &&
            (projectItem.MaintenanceSubCategoryGlobal__c == 'Fencing' ||
            projectItem.MaintenanceSubCategoryGlobal__c == 'Gutters' ||
            projectItem.MaintenanceSubCategoryGlobal__c ==
            'Soffit/Fascia Repair')) ||
            (projectItem.MaintenanceCategoryGlobal__c == 'Interior General' &&
            (projectItem.MaintenanceSubCategoryGlobal__c == 'Demoltion' ||
            projectItem.MaintenanceSubCategoryGlobal__c == 'Doors' ||
            projectItem.MaintenanceSubCategoryGlobal__c == 'Sheetrock' ||
            projectItem.MaintenanceSubCategoryGlobal__c == 'Tile/Grout')) ||
            (projectItem.MaintenanceCategoryGlobal__c == 'Garage' &&
            (projectItem.MaintenanceSubCategoryGlobal__c == 'Door/Panel' ||
            projectItem.MaintenanceSubCategoryGlobal__c == 'Hardware' ||
            projectItem.MaintenanceSubCategoryGlobal__c == 'Repair/Service')) ||
            (projectItem.MaintenanceCategoryGlobal__c == 'Roof' &&
            projectItem.MaintenanceSubCategoryGlobal__c == 'Covered Patio') ||
            (projectItem.MaintenanceCategoryGlobal__c == 'Chimney' &&
            (projectItem.MaintenanceSubCategoryGlobal__c == 'Flue/Dampener' ||
            projectItem.MaintenanceSubCategoryGlobal__c == 'Rebuild')) ||
            (projectItem.MaintenanceCategoryGlobal__c == 'Landscaping' &&
            projectItem.MaintenanceSubCategoryGlobal__c == 'Concrete') ||
            (projectItem.MaintenanceCategoryGlobal__c == 'Pest Control' &&
            (projectItem.MaintenanceSubCategoryGlobal__c == 'Rodent Control' ||
            projectItem.MaintenanceSubCategoryGlobal__c ==
            'Termite Control')) ||
            (projectItem.MaintenanceCategoryGlobal__c == 'Locks' &&
            (projectItem.MaintenanceSubCategoryGlobal__c == 'Rekey'))
        ) {
            projectItem.Priority__c = 'High';
        } else {
            projectItem.Priority__c = 'Medium';
        }
        System.debug(
            'workOrderTag is not blank: ' + String.isNotBlank(workOrderTag)
        );
        System.debug('workOrderTag: ' + workOrderTag);
        if (String.isNotBlank(workOrderTag) && workOrderTag == '1-90') {
            List<Project_Item__c> pItemList = [
                SELECT Id, Vendor_Acct__c
                FROM Project_Item__c
                WHERE
                    Project__r.House__c = :cs.Property__c
                    AND CategoryGlobal__c = :projectItem.MaintenanceCategoryGlobal__c
                    AND SubCategoryGlobal__c = :projectItem.MaintenanceSubCategoryGlobal__c
                LIMIT 1
            ];
            if (!pItemList.isEmpty()) {
                projectItem.Vendor_Acct__c = pItemList[0].Vendor_Acct__c;

                if (!bidWrapperList.isEmpty()) {
                    bidWrapperList[0].bid.Vendor__c = pItemList[0]
                        .Vendor_Acct__c;
                }
            } else {
                List<Project_Item__c> proItemList = [
                    SELECT Id, Vendor_Acct__c
                    FROM Project_Item__c
                    WHERE
                        Project__r.House__c = :cs.Property__c
                        AND CategoryGlobal__c = :projectItem.MaintenanceCategoryGlobal__c
                    LIMIT 1
                ];

                if (!proItemList.isEmpty()) {
                    projectItem.Vendor_Acct__c = proItemList[0].Vendor_Acct__c;

                    if (!bidWrapperList.isEmpty()) {
                        bidWrapperList[0].bid.Vendor__c = proItemList[0]
                            .Vendor_Acct__c;
                    }
                } else {
                    projectItem.Vendor_Acct__c = null;
                    if (!bidWrapperList.isEmpty()) {
                        bidWrapperList[0].bid.Vendor__c = null;
                    }
                }
            }
        }

        return null;
    }

    public PageReference bidTotalList() {
        Integer bidListSize = bidWrapperList.size();
        if (numberOfBids > bidListSize) {
            for (Integer i = 0; i < (numberOfBids - bidListSize); i++) {
                Project_Item_Bid__c bid = new Project_Item_Bid__c(
                    Bid_Fee__c = false
                );

                BidWrapper bidWrap = new BidWrapper();
                bidWrap.bid = bid;
                bidWrapperList.add(bidWrap);
            }
        } else if (numberOfBids < bidListSize) {
            Integer removeNum = bidListSize - 1;
            if (bidWrapperList.get(removeNum).bid.Id != null) {
                bidsToDelete.add(bidWrapperList.get(removeNum).bid);
                System.debug('bidsToDelete-----' + bidsToDelete);
            }
            bidWrapperList.remove(removeNum);
        } else {
            if (numberOfBids != null && numberOfBids > 0) {
                bidWrapperList.clear();
                for (Integer i = 0; i < numberOfBids; i++) {
                    Project_Item_Bid__c bid = new Project_Item_Bid__c(
                        Bid_Fee__c = false
                    );
                    if (
                        String.isNotBlank(acceptedRow) &&
                        acceptedRow == String.valueOf(i)
                    ) {
                        bid.Owner_Accepted__c = true;
                    }
                    BidWrapper bidWrap = new BidWrapper();
                    bidWrap.bid = bid;
                    bidWrapperList.add(bidWrap);
                }
            }
        }
        return null;
    }

    public PageReference bidAcceptedByOwner() {
        System.debug('acceptedRow---' + acceptedRow);
        System.debug('bidWrapperList---' + bidWrapperList);
        Decimal repairCost = 0;
        Decimal bidAmount = 0;
        Decimal markupAmount = 0;
        Integer i = 0;
        for (BidWrapper bidWrap : bidWrapperList) {
            System.debug(
                'bidWrap.bid.Markup_Amount__c---' + bidWrap.bid.Markup_Amount__c
            );
            if (
                String.isNotBlank(acceptedRow) &&
                Integer.valueOf(acceptedRow) == i
            ) {
                bidWrap.bid.Owner_Accepted__c = true;
                projectItem.Vendor_Acct__c = bidWrap.bid.Vendor__c;
                repairCost = bidWrap.bid.Repair_Cost__c == null
                    ? 0
                    : bidWrap.bid.Repair_Cost__c;
                markupAmount = bidWrap.bid.Markup_Amount__c == null
                    ? 0
                    : bidWrap.bid.Markup_Amount__c;

                projectItem.Vendor_Start_Date__c = System.today();
            } else {
                bidAmount += bidWrap.bid.Amount__c == null
                    ? 0
                    : bidWrap.bid.Amount__c;
            }
            i++;
        }

        totalRepairCost = repairCost + bidAmount + markupAmount;

        projectItem.Total_Repair_Cost__c = totalRepairCost;
        return null;
    }

    public List<SelectOption> getYesNo() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('No', 'No'));
        options.add(new SelectOption('Yes', 'Yes'));

        return options;
    }

    public List<SelectOption> getMaintenanceStatus() {
        List<SelectOption> options = new List<SelectOption>();

        Schema.DescribeFieldResult fieldResult = Project_Item__c.Maintenance_Status__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f : ple) {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }
        return options;
    }

    public List<SelectOption> getOver400Status() {
        List<SelectOption> options = new List<SelectOption>();

        Schema.DescribeFieldResult fieldResult = Project_Item__c.Over_400_Status__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f : ple) {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }
        return options;
    }

    public List<SelectOption> getMaintenanceCategory() {
        List<SelectOption> options = new List<SelectOption>();

        Schema.DescribeFieldResult fieldResult = Project_Item__c.MaintenanceCategoryGlobal__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f : ple) {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }
        return options;
    }

    public List<SelectOption> getMaintenanceSubCategory() {
        List<SelectOption> options = new List<SelectOption>();

        Schema.DescribeFieldResult fieldResult = Project_Item__c.MaintenanceSubCategoryGlobal__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f : ple) {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }
        return options;
    }

    public Boolean hasErrors() {
        Boolean isAccepted = false;

        for (BidWrapper bidWrap : bidWrapperList) {
            if (bidWrap.bid.Vendor__c == null) {
                ApexPages.addmessage(
                    new ApexPages.message(
                        ApexPages.severity.ERROR,
                        'Please choose Vendor.'
                    )
                );
                return true;
            }
        }

        for (BidWrapper bidWrap : bidWrapperList) {
            if (bidWrap.bid.Owner_Accepted__c) {
                isAccepted = true;
                break;
            }
        }

        if (!isAccepted) {
            ApexPages.addmessage(
                new ApexPages.message(
                    ApexPages.severity.ERROR,
                    'Please select atleast one bid.'
                )
            );
            return true;
        }

        if (
            projectItem.Total_Repair_Cost__c > getOVER_400() &&
            projectItem.Over_400_Status__c == null
        ) {
            System.debug(
                'projectItem.Total_Repair_Cost__c------' +
                projectItem.Total_Repair_Cost__c
            );
            ApexPages.addmessage(
                new ApexPages.message(
                    ApexPages.severity.ERROR,
                    'Please choose Over $400 Status.'
                )
            );
            return true;
        }
        if (String.isBlank(projectItem.Maintenance_Status__c)) {
            ApexPages.addmessage(
                new ApexPages.message(
                    ApexPages.severity.ERROR,
                    'Please choose Maintenance Status.'
                )
            );
            return true;
        }
        if (String.isBlank(projectItem.MaintenanceCategoryGlobal__c)) {
            ApexPages.addmessage(
                new ApexPages.message(
                    ApexPages.severity.ERROR,
                    'Please choose Maintenance Main Category.'
                )
            );
            return true;
        }
        if (String.isBlank(cs.OwnerId)) {
            ApexPages.addmessage(
                new ApexPages.message(
                    ApexPages.severity.ERROR,
                    'Please choose a Case Owner.'
                )
            );
            return true;
        }

        return false;
    }

    public PageReference sendEmail() {
        upsert project;
        upsert projectItem;
        List<Project_Item_Bid__c> projectItemBidList = new List<Project_Item_Bid__c>();
        for (BidWrapper bidWrap : bidWrapperList) {
            projectItemBidList.add(bidWrap.bid);
        }
        upsert projectItemBidList;

        List<String> toAddress = new List<String>();
        List<String> toccAddress = new List<String>();
        List<String> tobccAddress = new List<String>();

        /*if(String.isBlank(salesRepEmail)){
String returnMssage = 'Please add the email at the Customer Service Assignment Email if you want to generate Task for Customer Service.'; 
ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.FATAL, returnMssage));
return null;   
}*/

        Map<String, String> previewAdresses = new Map<String, String>{
            'TO' => toAdr
        };
        system.debug('@@ to adr' + toAdr);
        system.debug('@@ cc ' + ccAdr);
        system.debug('@@ bcc ' + bccAdr);
        if (String.isNotBlank(salesRepEmail)) {
            previewAdresses.put('SalesRep', salesRepEmail);
        }
        if (String.isNotBlank(ccAdr)) {
            previewAdresses.put('CC', ccAdr);
        }
        if (String.isNotBlank(bccAdr)) {
            previewAdresses.put('BCC', bccAdr);
        }

        for (String adressType : previewAdresses.keySet()) {
            String emailAdr = previewAdresses.get(adressType);
            if (String.isNotBlank(emailAdr)) {
                for (String adr : emailAdr.split(';')) {
                    String adrToAdd = adr.trim();

                    String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
                    Pattern myPattern = Pattern.compile(emailRegex);
                    Matcher myMatcher = myPattern.matcher(adrToAdd);

                    if (!myMatcher.matches()) {
                        String returnMssage =
                            'Format issue with ' +
                            adressType +
                            ' Address.';
                        ApexPages.addMessage(
                            new ApexPages.Message(
                                ApexPages.SEVERITY.FATAL,
                                returnMssage
                            )
                        );
                        return null;
                    } else {
                        if (adressType == 'TO') {
                            system.debug('@@@ ' + adrToAdd);
                            toAddress.add(adrToAdd);
                        }
                        if (adressType == 'CC') {
                            toccAddress.add(adrToAdd);
                        }
                        if (adressType == 'BCC') {
                            tobccAddress.add(adrToAdd);
                        }
                    }
                }
            }
        }

        if (toAddress.isEmpty()) {
            String returnMssage = 'Please add the email at the To address if you want this to be send email.';
            ApexPages.addMessage(
                new ApexPages.Message(ApexPages.SEVERITY.FATAL, returnMssage)
            );
            return null;
        }

        String templateName = projectItem.Over_400_Status__c ==
            'Over $400 Post-work Notification (QOL)'
            ? 'Over_400_Post_work_Notification_QOL'
            : 'Over_400_Pre_work_Approval';
        EmailTemplate emailTemplate = [
            SELECT Id, Subject, Body
            FROM EmailTemplate
            WHERE DeveloperName = :templateName
        ];

        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();

        OrgWideEmailAddress[] owea = [
            SELECT Id
            FROM OrgWideEmailAddress
            WHERE Address = 'ppmgmaintenance@premierpropertymg.com'
        ];

        Integer j = 0;
        Id conId = null;
        List<String> extraToEmails = new List<String>();
        List<String> sendConToEmails = new List<String>();

        String bodyVal =
            emailContentBefore +
            '' +
            projectItem.Over_400_Description__c;
        String bidString = projectItem.Over_400_Description__c;
        for (BidWrapper bidWrap : bidWrapperList) {
            if (
                bidWrap.bid.Vendor__c != null &&
                String.isNotBlank(bidWrap.bid.SOW_Description__c)
            ) {
                Decimal repairCost = bidWrap.bid.Repair_Cost__c == null
                    ? 0
                    : bidWrap.bid.Repair_Cost__c;
                Decimal markupAmount = bidWrap.bid.Markup_Amount__c == null
                    ? 0
                    : bidWrap.bid.Markup_Amount__c;
                Decimal bidAmt = repairCost + markupAmount;
                List<String> args = new List<String>{
                    '0',
                    'number',
                    '###,###,##0.00'
                };
                String bidAmtFormat =
                    '$' + String.format(bidAmt.format(), args);
                System.debug('bidAmtFormat----' + bidAmtFormat);
                bodyVal +=
                    '<br/><br/>' +
                    bidWrap.vendorName +
                    ': ' +
                    bidWrap.bid.SOW_Description__c +
                    '<br/><br/> Amount: ' +
                    bidAmtFormat;
                bidString +=
                    '<br/><br/>' +
                    bidWrap.vendorName +
                    ': ' +
                    bidWrap.bid.SOW_Description__c +
                    'Amount: ' +
                    bidAmtFormat;
            }
        }
        bodyVal += emailContentAfter;
        String subject = emailTemplate.Subject;
        System.debug('houseStreetAdr----' + houseStreetAdr);
        System.debug('subject----' + subject);

        if (String.isNotBlank(houseStreetAdr)) {
            subject = subject.replace(
                '{!Project_Item__c.House_Street_Address1__c}',
                houseStreetAdr
            );
        } else {
            subject = subject.replace(
                '{!Project_Item__c.House_Street_Address1__c}',
                ' '
            );
        }
        //=============================

        boolean CheckPrimary = true;
        list<Contact> ConListPrimary = new List<Contact>();
        list<Contact> ConListNonPrimary = new List<Contact>();

        for (Contact con : [
            SELECT Id, Name, Is_Primary__c, Email
            FROM Contact
            WHERE
                Email IN :toAddress
                AND AccountId = :cs.Property__r.Investor__c
        ]) {
            if (con.Is_Primary__c == true) {
                ConListPrimary.add(con);
                system.debug('primary contact ' + con);
            } else {
                ConListNonPrimary.add(con);
                system.debug('not primary contact ' + con);
            }
        }

        // Send Email to Only Primary Contacts   ==============>
        if (ConListPrimary.size() > 0) {
            CheckPrimary = false;
            for (Contact con : ConListPrimary) {
                if (con.Email != null && con.Name != null) {
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    if (
                        Label.PPMGEmailServiceEmailId != null &&
                        Label.PPMGEmailServiceEmailId != ''
                    ) {
                        mail.setReplyTo(Label.PPMGEmailServiceEmailId);
                    }
                    if (j == 0) {
                        conId = con.Id;
                        if (!toccAddress.isEmpty()) {
                            mail.setCcAddresses(toccAddress);
                        }
                        if (!tobccAddress.isEmpty()) {
                            mail.setBccAddresses(tobccAddress);
                        }
                    }

                    List<String> sendTo = new List<String>();
                    sendTo.add(con.Email);
                    sendConToEmails.add(con.Email);
                    mail.setToAddresses(sendTo);
                    system.debug('@@ contact send to ' + sendTo);

                    mail.setTemplateId(emailTemplate.Id);
                    mail.setSubject(subject);
                    System.debug('bodyVal----' + bodyVal);

                    String bodyHtml = bodyVal.replace(
                        'Hello ,',
                        'Hello ' + con.Name + ','
                    );
                    mail.setHTMLBody(bodyHtml);
                    bidString = bidString.replaceAll('<br/>', '\r\n');

                    String plainText =
                        emailContentBefore.stripHtmlTags() +
                        '' +
                        bidString +
                        '' +
                        emailContentAfter.stripHtmlTags();
                    plainText = plainText.replace(
                        'Hello ,',
                        'Hello ' + con.Name + ','
                    );
                    plainText = plainText.substringBefore(
                        '<p style="color:white">'
                    );
                    mail.setPlainTextBody(plainText);
                    mail.setTargetObjectId(con.Id);
                    mail.setWhatId(projectItem.Id);
                    // Vikram modified 04/13/2019
                    if (owea.size() > 0) {
                        mail.setOrgWideEmailAddressId(owea.get(0).Id);
                    }
                    //mail.setReplyTo(Label.MI_Email);

                    if (emailAttachmentListWrapper.size() > 0) {
                        List<Messaging.EmailFileAttachment> emailAttachments = new List<Messaging.EmailFileAttachment>();
                        List<String> docIds = new List<String>();
                        for (
                            EmailAttachmentWrapper wrapper : emailAttachmentListWrapper
                        ) {
                            docIds.add(wrapper.fileId);
                        }
                        mail.setEntityAttachments(docIds);
                    }

                    mails.add(mail);
                    //system.assert(false,mails);
                    j++;
                }
            }
        }
        // Send Email Non Primary Contacts
        if (CheckPrimary == true && ConListNonPrimary.size() > 0) {
            for (Contact con : ConListNonPrimary) {
                if (con.Email != null && con.Name != null) {
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    if (
                        Label.PPMGEmailServiceEmailId != null &&
                        Label.PPMGEmailServiceEmailId != ''
                    ) {
                        mail.setReplyTo(Label.PPMGEmailServiceEmailId);
                    }
                    if (j == 0) {
                        conId = con.Id;
                        if (!toccAddress.isEmpty()) {
                            mail.setCcAddresses(toccAddress);
                        }
                        if (!tobccAddress.isEmpty()) {
                            mail.setBccAddresses(tobccAddress);
                        }
                    }

                    List<String> sendTo = new List<String>();
                    sendTo.add(con.Email);
                    sendConToEmails.add(con.Email);
                    system.debug('@@ sendToAdds' + sendTo);
                    mail.setToAddresses(sendTo);

                    mail.setTemplateId(emailTemplate.Id);
                    mail.setSubject(subject);
                    System.debug('bodyVal----' + bodyVal);

                    String bodyHtml = bodyVal.replace(
                        'Hello ,',
                        'Hello ' + con.Name + ','
                    );
                    mail.setHTMLBody(bodyHtml);
                    bidString = bidString.replaceAll('<br/>', '\r\n');

                    String plainText =
                        emailContentBefore.stripHtmlTags() +
                        '' +
                        bidString +
                        '' +
                        emailContentAfter.stripHtmlTags();
                    plainText = plainText.replace(
                        'Hello ,',
                        'Hello ' + con.Name + ','
                    );
                    plainText = plainText.substringBefore(
                        '<p style="color:white">'
                    );
                    mail.setPlainTextBody(plainText);
                    mail.setTargetObjectId(con.Id);
                    mail.setWhatId(projectItem.Id);
                    // Vikram modified 04/13/2019
                    if (owea.size() > 0) {
                        mail.setOrgWideEmailAddressId(owea.get(0).Id);
                    }
                    //mail.setReplyTo(Label.MI_Email);

                    if (emailAttachmentListWrapper.size() > 0) {
                        List<Messaging.EmailFileAttachment> emailAttachments = new List<Messaging.EmailFileAttachment>();
                        List<String> docIds = new List<String>();
                        for (
                            EmailAttachmentWrapper wrapper : emailAttachmentListWrapper
                        ) {
                            docIds.add(wrapper.fileId);
                        }
                        mail.setEntityAttachments(docIds);
                    }

                    mails.add(mail);
                    //system.assert(false,mails);
                    j++;
                }
            }
        }

        //=====================
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        for (String eml : toAddress) {
            if (!sendConToEmails.contains(eml)) {
                system.debug('@@ eml ' + eml);
                extraToEmails.add(eml);
            }
        }

        system.debug('@@' + mails);
        system.debug('@@' + extraToEmails);
        if (!extraToEmails.isEmpty() && !mails.isEmpty()) {
            system.debug('mails fouond');
            List<String> sendToEmails = new List<String>();
            sendToEmails.addAll(mails[0].getToAddresses());
            sendToEmails.addAll(extraToEmails);
            mails[0].setToAddresses(sendToEmails);
        }

        try {
            List<Task> taskList = new List<Task>();
            Id customServiceRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName()
                .get('Customer Service')
                .getRecordTypeId();
            Messaging.SendEmailResult[] result = Messaging.sendEmail(mails);
            system.debug('asdasdasd' + result);
            Integer i = 0;
            for (Messaging.SendEmailResult rr : result) {
                if (
                    rr.IsSuccess() &&
                    cs.Property__r.Investor__r.Customer_Service_Assignment__c !=
                    null
                ) {
                    taskList.add(
                        new Task(
                            Subject = Label.Call_Owner_Task +
                                ' - ' +
                                cs.Property__r.Street_Address__c,
                            ActivityDate = System.today(),
                            Priority = 'Urgent',
                            OwnerId = cs.Property__r.Investor__r.Customer_Service_Assignment__c,
                            Status = 'Not Started',
                            Type = 'Call',
                            Type__c = 'Call',
                            WhatId = cs.Property__r.Investor__c,
                            WhoId = conId,
                            Description = mails[i].getPlainTextBody(),
                            RecordTypeId = customServiceRecordTypeId
                        )
                    );
                    /* previous value for WhatId = WhatId=projectItem.Id*/
                    break;
                }
                if (
                    rr.IsSuccess() &&
                    cs.Property__r.Investor__r.Customer_Service_Assignment__c ==
                    null &&
                    salesRepEmail != null
                ) {
                    List<User> csRep = [
                        SELECT Id
                        FROM User
                        WHERE Email = :salesRepEmail
                    ];
                    if (!csRep.isEmpty()) {
                        taskList.add(new Task(Subject = Label.Call_Owner_Task +' - ' +cs.Property__r.Street_Address__c,ActivityDate = System.today(),Priority = 'Urgent',OwnerId = csRep[0].Id,Status = 'Not Started',Type = 'Call',Type__c = 'Call',WhatId = cs.Property__r.Investor__c,WhoId = conId,Description = mails[i].getPlainTextBody(),RecordTypeId = customServiceRecordTypeId
                            )
                            /* previous value for WhatId = WhatId=projectItem.Id*/
                        );
                    }
                    break;
                }
                i++;
            }

            cs.Status = 'Open - Waiting on Owner Approval';
            update cs;

            if (!taskList.isEmpty()) {
                insert taskList;
            }

            System.debug('selectedButton----' + selectedButton);
            showPopup = false;

            if (selectedButton == 'Save') {
                PageReference pgRef = new PageReference('/' + cs.Id);
                pgRef.setRedirect(true);
                return pgRef;
            }
            if (selectedButton == 'SaveNew') {
                PageReference pgRef = new PageReference(
                    '/apex/ProjectItemFromCase?id=' + cs.Id
                );
                pgRef.setRedirect(true);
                return pgRef;
            }
            return null;
        } catch (exception e) {
            System.debug(e.getMessage());
            ApexPages.addmessage(
                new ApexPages.message(ApexPages.severity.ERROR, e.getMessage())
            );
            return null;
        }
    }

    public PageReference save() {
        if (!hasErrors()) {
            try {
                // Update Case Status
                if (cs.Status != 'Closed') {
                    cs.status = 'Pending - Under Repair';
                }
                if (
                    projectItem.Total_Repair_Cost__c > getOVER_400() &&
                    projectItem.Over_400_Status__c != null
                ) {
                    cs.Status = 'Open - Waiting on Owner Approval';
                }
                update cs;

                Id recordId = ApexPages.currentPage().getParameters().get('id');
                System.debug('first30days-----' + first30days);
                System.debug(
                    'projectLastLeaseList-----' + projectLastLeaseList
                );
                //if(projectItem.Maintenance_Status__c == 'Closed' && first30days && !projectLastLeaseList.isEmpty()){

                if (
                    projectItem.Maintenance_Status__c == 'Active Dispatched' &&
                    first30days &&
                    !projectLastLeaseList.isEmpty() &&
                    projectLastLeaseList[0].Maint_After_Move_In__c == false
                ) {
                    Project__c projectRehabUpdate = new Project__c(
                        Id = projectLastLeaseList[0].Id,
                        Maint_After_Move_In__c = first30days
                    );
                    update projectRehabUpdate;

                    System.debug(
                        'projectRehabUpdate-----' + projectRehabUpdate
                    );
                }

                if (
                    projectItem.Maintenance_Status__c == 'Active Dispatched' &&
                    first30days &&
                    !projectLastLeaseList.isEmpty() &&
                    projectLastLeaseList[0].Maint_After_Move_In__c == true
                ) {
                    Project__c projectRehabUpdate = new Project__c(
                        Id = projectLastLeaseList[0].Id,
                        Maint_After_Move_In__c = first30days,
                        Maint_After_Move_In_Initial__c = true
                    );
                    update projectRehabUpdate;

                    System.debug(
                        'projectRehabUpdate-----' + projectRehabUpdate
                    );
                }

                if (
                    (projectItem.Maintenance_Status__c ==
                    'Closed - Not Fixing' ||
                    projectItem.Maintenance_Status__c ==
                    'Closed - Inactivity') &&
                    first30days &&
                    !projectLastLeaseList.isEmpty() &&
                    projectLastLeaseList[0].Maint_After_Move_In_Initial__c ==
                    false
                ) {
                    Project__c projectRehabUpdate = new Project__c(
                        Id = projectLastLeaseList[0].Id,
                        Maint_After_Move_In__c = false
                    );
                    update projectRehabUpdate;

                    System.debug(
                        'projectRehabUpdate-----' + projectRehabUpdate
                    );
                }

                if (
                    (projectItem.Maintenance_Status__c ==
                    'Closed - Not Fixing' ||
                    projectItem.Maintenance_Status__c ==
                    'Closed - Inactivity') &&
                    first30days &&
                    !projectLastLeaseList.isEmpty() &&
                    projectLastLeaseList[0].Maint_After_Move_In_Initial__c ==
                    true
                ) {
                    Project__c projectRehabUpdate = new Project__c(
                        Id = projectLastLeaseList[0].Id,
                        Maint_After_Move_In__c = true
                    );
                    update projectRehabUpdate;

                    System.debug(
                        'projectRehabUpdate-----' + projectRehabUpdate
                    );
                }

                if (!first30days && !projectLastLeaseList.isEmpty()) {
                    Project__c projectRehabUpdate = new Project__c(
                        Id = projectLastLeaseList[0].Id,
                        Maint_After_Move_In__c = first30days
                    );
                    update projectRehabUpdate;

                    System.debug(
                        'projectRehabUpdate-----' + projectRehabUpdate
                    );
                }

                upsert project;

                if (projectItem.Project__c == null) {
                    projectItem.Project__c = project.Id;
                }

                if (
                    projectItem.Maintenance_Status__c == 'Active Dispatched' &&
                    !projectItem.Is_Active_Dispatched__c
                ) {
                    projectItem.Is_Active_Dispatched__c = true;
                }

                projectItem.Rehab_Warranty_Stage__c = workOrderTag;

                if (!bidWrapperList.isEmpty()) {
                    if (bidWrapperList.size() == 1) {
                        projectItem.SOW_Description__c = bidWrapperList[0]
                            .bid.SOW_Description__c;
                    } else {
                        for (BidWrapper bidWrap : bidWrapperList) {
                            if (bidWrap.bid.Owner_Accepted__c) {
                                projectItem.SOW_Description__c = bidWrap.bid.SOW_Description__c;
                            }
                        }
                    }
                }

                if (projectItem.Id == null) {
                    List<Project_Item__c> projectItemLastList = [
                        SELECT Id, Name
                        FROM Project_Item__c
                        WHERE
                            Case__c = :cs.Id
                            AND RecordType.Name = 'Maintenance'
                        ORDER BY Id DESC
                        LIMIT 1
                    ];

                    num = null;
                    if (!projectItemLastList.isEmpty()) {
                        String name = projectItemLastList[0].Name;
                        if (
                            name.contains(
                                'WO-' +
                                    cs.Property__r.Market__c +
                                    '-' +
                                    cs.CaseNumber
                            )
                        ) {
                            name = name.substringAfterLast('-');
                            num = String.valueOf(Integer.valueOf(name) + 1);
                        } else {
                            num = '01';
                        }
                        System.debug('num-----' + num);
                    } else {
                        num = '01';
                        System.debug('num-----' + num);
                    }

                    numLength = num.length();
                    num = numLength == 1 ? '0' + num : num;
                    List<Project__c> projectList = [
                        SELECT
                            Id,
                            Maint_After_Move_In_Initial__c,
                            Maint_After_Move_In__c,
                            Last_Lease_Closing_Date__c,
                            House__c,
                            House__r.Name,
                            House__r.Market__c
                        FROM Project__c
                        WHERE
                            Id = :project.Id
                            AND Case__c = :cs.Id
                            AND RecordType.Name = 'Maintenance'
                    ];
                    if (!projectList.isEmpty()) {
                        project = projectList[0];
                        projectItem.Name =
                            'WO-' +
                            project.House__r.Market__c +
                            '-' +
                            cs.CaseNumber +
                            '-' +
                            num;
                    }
                }

                upsert projectItem;
                System.debug('projectItem-----' + projectItem);

                String bidNum = null;

                List<Project_Item_Bid__c> projectBidLastList = [
                    SELECT Id, Name
                    FROM Project_Item_Bid__c
                    WHERE Project_Item__c = :projectItem.Id
                    ORDER BY Id DESC
                    LIMIT 1
                ];

                List<Project_Item_Bid__c> projectItemBidList = new List<Project_Item_Bid__c>();
                Integer i = 0;
                Set<Id> vendorIds = new Set<Id>();
                String numBid = '';
                System.debug('numBid-----' + numBid);
                for (BidWrapper bidWrap : bidWrapperList) {
                    i++;
                    if (bidWrap.bid.Vendor__c != null) {
                        vendorIds.add(bidWrap.bid.Vendor__c);
                    }
                    if (
                        bidWrap.bid.Amount__c != null &&
                        bidWrap.bid.Amount__c != 0
                    ) {
                        bidWrap.bid.Bid_Fee__c = true;
                    }
                    if (bidWrap.bid.Id == null) {
                        if (projectBidLastList.isEmpty()) {
                            bidWrap.bid.Name =
                                projectItem.Name +
                                '-' +
                                (i < 10 ? '0' + i : String.valueOf(i));
                        } else {
                            System.debug(
                                'projectBidLastList-----' + projectBidLastList
                            );
                            if (String.isBlank(numBid)) {
                                String name = projectBidLastList[0].Name;
                                name = name.substringAfterLast('-');
                                numBid = String.valueOf(
                                    Integer.valueOf(name) + 1
                                );
                                System.debug('numbid-----' + numBid);
                            } else {
                                numBid = String.valueOf(
                                    Integer.valueOf(numBid) + 1
                                );
                                System.debug('numBid-----' + numBid);
                            }

                            Integer numLengthBid = numBid.length();
                            numBid = numLengthBid == 1 ? '0' + numBid : numBid;
                            bidWrap.bid.Name = projectItem.Name + '-' + numBid;
                        }
                        bidWrap.bid.Project_Item__c = projectItem.Id;
                    }
                    projectItemBidList.add(bidWrap.bid);
                }
                upsert projectItemBidList;
                System.debug('projectItemBidList-----' + projectItemBidList);

                if (!bidsToDelete.isEmpty()) {
                    delete bidsToDelete;
                    bidsToDelete.clear();
                }

                Map<Id, Account> vendorMap = new Map<Id, Account>(
                    [SELECT Id, Name FROM Account WHERE Id = :vendorIds]
                );

                for (BidWrapper bidWrap : bidWrapperList) {
                    if (bidWrap.bid.Vendor__c != null && !vendorMap.isEmpty()) {
                        if (vendorMap.containsKey(bidWrap.bid.Vendor__c)) {
                            bidWrap.vendorName = vendorMap.get(
                                    bidWrap.bid.Vendor__c
                                )
                                .Name;
                        }
                    }
                }

                if (projectItem.Total_Repair_Cost__c < getOVER_400()) {
                    if (selectedButton == 'Save') {
                        PageReference pgRef = new PageReference('/' + cs.Id);
                        pgRef.setRedirect(true);
                        return pgRef;
                    }
                    if (selectedButton == 'SaveNew') {
                        PageReference pgRef = new PageReference(
                            '/apex/ProjectItemFromCase?id=' + cs.Id
                        );
                        pgRef.setRedirect(true);
                        return pgRef;
                    }
                } else {
                    if (projectItem.Total_Repair_Cost__c > getOVER_400() && projectItem.Over_400_Status__c != null) {
                        String templateName = (projectItem.Over_400_Status__c == 'Over $400 Post-work Notification (QOL)') ? 'Over_400_Post_work_Notification_QOL' : 'Over_400_Pre_work_Approval';
                        EmailTemplate emailTemplate = [SELECT Id, Subject, Body, HtmlValue FROM EmailTemplate WHERE DeveloperName = :templateName];
                        String emailContent = emailTemplate.HtmlValue;
                        
                        List<String> toEmails = new List<String>();
                        String greetings = '';
                        
                        List<Contact> conList = [SELECT Id, Name, Email FROM Contact WHERE AccountId = :cs.Property__r.Investor__c];
                        for (Contact con : conList) {
                            if (con.Email != null && con.Name != null) {
                                toEmails.add(con.Email);
                            }
                        }
                
                        if (toEmails.isEmpty() && cs.Property__r.Investor__r.Customer_Service_Assignment__r.Email != null) {
                            toEmails.add(cs.Property__r.Investor__r.Customer_Service_Assignment__r.Email);
                            salesRepEmail = cs.Property__r.Investor__r.Customer_Service_Assignment__r.Email;
                        }
                        
                        toAdr = String.join(toEmails, ';');
                        
                        emailContent = emailContent.replace('{!Contact.Name}', greetings)
                            .replace('{!Project_Item__c.House_Address__c}', houseAdr)
                            .replace('{!Project_Item__c.Id}', Projectitem.id)
                            .replace('{!$User.Id}', UserInfo.getUserId())
                            .replace('{!Project_Item__c.Name}', Projectitem.Name);
                
                        emailContentBefore = emailContent.substringBefore('{!Project_Item__c.Over_400_Description__c}');
                        emailContentAfter = emailContent.substringAfter('{!Project_Item__c.Over_400_Description__c}');
                
                        showPopup = true;
                    }
				}

            } catch (exception e) {
                System.debug(
                    'error---' + e.getLineNumber() + ':' + e.getMessage()
                );
                ApexPages.addmessage(
                    new ApexPages.message(
                        ApexPages.severity.ERROR,
                        e.getMessage()
                    )
                );
                return null;
            }
        }

        return null;
    }

    public PageReference saveProjectItem() {
        try {
            showPopup = false;
            PageReference pgRef = save();

            return pgRef;
        } catch (Exception e) {
            System.debug(
                'ErrLine----' + e.getLineNumber() + ':' + e.getMessage()
            );
            ApexPages.addmessage(
                new ApexPages.message(ApexPages.severity.ERROR, e.getMessage())
            );
        }
        return null;
    }

    public PageReference cancel() {
        PageReference pgRef = new PageReference('/' + cs.Id);
        pgRef.setRedirect(true);
        return pgRef;
    }

    public List<SelectOption> getFileLocation() {
        List<SelectOption> opts = new List<SelectOption>();
        opts.add(new SelectOption('', ' - Select - '));
        opts.add(new SelectOption('My Computer', 'My Computer'));
        opts.add(
            new SelectOption('Notes & Attachments', 'Notes & Attachments')
        );

        return opts;
    }

    public void refreshDocumentSection() {
        error = '';

        try {
            System.debug(
                'selectedDocumentFolder------' + selectedDocumentFolder
            );
        } catch (Exception e) {
            error = e.getMessage();
        }
    }

    public void refreshDocumentSection1() {
        error = '';
        //system.assert(false,emailAttachmentListWrapper);
        try {
            System.debug(
                'selectedDocumentFolder------' + selectedDocumentFolder
            );
        } catch (Exception e) {
            error = e.getMessage();
        }
    }

    public void attachFile() {
        try {
            error = '';

            if (
                String.isNotBlank(selectedDocumentFolder) &&
                selectedDocumentFolder == 'Notes & Attachments'
            ) {
                for (DocumentWrapper wrp : docWrapList) {
                    if (wrp.isSelected) {
                        EmailAttachmentWrapper wrapper = new EmailAttachmentWrapper();
                        Id selectedId = Id.valueOf(wrp.value);
                        if (allFiles.containsKey(selectedId)) {
                            ContentVersion chosenAttachment = allFiles.get(
                                selectedId
                            );
                            System.debug(
                                '===================FirstPublishLocationId------' +
                                chosenAttachment.FirstPublishLocationId
                            );
                            wrapper.name = chosenAttachment.Title;
                            wrapper.location = 'Notes & Attachments';
                            wrapper.fileId = selectedId;
                            emailAttachmentListWrapper.add(wrapper);
                            System.debug(
                                '===================emailAttachmentListWrapper------' +
                                emailAttachmentListWrapper.size()
                            );
                        }
                    }
                }
            } else if (
                String.isNotBlank(selectedDocumentFolder) &&
                selectedDocumentFolder == 'My Computer'
            ) {
                if (newFileId != null && newFileId != '') {
                    System.debug(
                        '===================newFileId------' + newFileId
                    );
                    Set<Id> cvIds = new Set<Id>();
                    for (String cvId : newFileId.split(',')) {
                        cvIds.add(cvId);
                    }
                    System.debug('===================cvIds------' + cvIds);
                    for (ContentVersion cv : [
                        SELECT Id, Title, FirstPublishLocationId
                        FROM ContentVersion
                        WHERE Id IN :cvIds
                    ]) {
                        System.debug(
                            '===================FirstPublishLocationId------' +
                            cv.FirstPublishLocationId
                        );
                        if (!allFiles.containsKey(cv.Id)) {
                            EmailAttachmentWrapper wrapper = new EmailAttachmentWrapper();
                            wrapper.name = cv.Title;
                            wrapper.location = 'My Computer';
                            wrapper.fileId = cv.Id;
                            emailAttachmentListWrapper.add(wrapper);

                            allFiles.put(cv.Id, cv);
                        }
                    }
                }
                System.debug('===================allFiles------' + allFiles);
                System.debug(
                    '===================emailAttachmentListWrapper------' +
                    emailAttachmentListWrapper.size()
                );
            }

            selectedDocumentFolder = '';
        } catch (Exception e) {
            System.debug('e---- ' + e.getMessage());
            System.debug('e---- ' + e.getLineNumber());
            error = e.getMessage();
        }
    }

    public void deleteAttachment() {
        try {
            error = '';
            if (String.isNotBlank(rowIndexAttach)) {
                EmailAttachmentWrapper wrapper = emailAttachmentListWrapper.get(
                    Integer.valueOf(rowIndexAttach)
                );
                if (wrapper.location == 'My Computer') {
                    emailAttachmentListWrapper.remove(
                        Integer.valueOf(rowIndexAttach)
                    );
                    ContentVersion cvToDelete = allFiles.get(wrapper.fileId);
                    allFiles.remove(wrapper.fileId);

                    List<ContentDocument> listToDelete = new List<ContentDocument>();
                    List<ContentVersion> listToInsert = new List<ContentVersion>();
                    for (ContentVersion conver : [
                        SELECT Id, ContentDocumentId
                        FROM ContentVersion
                        WHERE Id = :wrapper.fileId
                    ]) {
                        listToDelete.add(
                            new ContentDocument(Id = conver.ContentDocumentId)
                        );
                    }

                    delete listToDelete;
                } else {
                    emailAttachmentListWrapper.remove(
                        Integer.valueOf(rowIndexAttach)
                    );
                }
            }
        } catch (Exception e) {
            error = e.getMessage();
        }
    }

    public class EmailAttachmentWrapper {
        public String name { get; set; }
        public String location { get; set; }
        private Id fileId;
    }

    public class BidWrapper {
        public Project_Item_Bid__c bid { get; set; }
        public String vendorName { get; set; }
    }

    public class ContentVersionWrapper {
        public ContentVersion contVer { get; set; }
        public Boolean isSelected { get; set; }

        public ContentVersionWrapper(ContentVersion cv, Boolean isSel) {
            this.contVer = cv;
            this.isSelected = isSel;
        }
    }

    // Wrapper Class
    public class DocumentWrapper {
        public Boolean isSelected { get; set; }
        public String label { get; set; }
        public String value { get; set; }

        public DocumentWrapper(Boolean sel, String lbl, String val) {
            this.isSelected = sel;
            this.label = lbl;
            this.value = val;
        }
    }
}