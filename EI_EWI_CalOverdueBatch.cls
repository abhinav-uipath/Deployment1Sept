global class EI_EWI_CalOverdueBatch implements Database.Batchable<sObject>, database.AllowsCallouts, Database.Stateful {
    //to get the case recordTypeId
    Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute EW Insured').getRecordTypeId();
    Public Double overduedays;
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'select Id,Status,Respond_date__c,OwnerId,'
            + ' Disputed_Funds_Received__c,Consent_withdrawn_date__c,Evidence_of_court_action_received__c,Dispute_Reference__c,Previous_owner__c,'
            +' AGLL_Respond_Evidance_Gathering__c,TT_respond_evidence_gathering__c,Counter__c,Deposit_Account_Number__r.Property_Address_WO_Country__c'
            + ' from Case WHERE RecordtypeId=:devRecordTypeId ' ; // AND ID = \'5003L000005OQjYQAW\'
        return database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Case> caseList){ 
        try{
            Map<Id,Case> mapCase = new Map<Id, Case>(caseList);
            List<Case> listAllDisputedCase= new List<Case>();           
            List<Credit_Control__c> updatecreditlist = new List<Credit_Control__c>();      
            DateTime startdate;
            DateTime enddate;
            Double noofDays;
            
            listAllDisputedCase=[Select Id,Status,
                                 Disputed_Funds_Received__c,
                                 Deposit_repaid_Start_Date__c,Dispute_Reference__c,
                                 (Select NewValue, OldValue ,CreatedDate, Field FROM Histories where Field = 'Status' order by Createddate desc) from Case 
                                 where RecordtypeId=:devRecordTypeId AND Disputed_Funds_Received__c = false
                                 AND Id=: mapCase.keySet() ];

            system.debug('++disputed'+listAllDisputedCase);
            
            List<Credit_Control__c> creditlist = New List<Credit_Control__c>();
            List<CaseHistory> casehistorylist = New List<CaseHistory>();
            Map<Id, Credit_Control__c> mapCaseIdCredit = new Map<Id, Credit_Control__c>();
            Credit_Control__c cc;
            
            for(Credit_Control__c cobj : [Select Id,Next_step__c,Name,Dispute__c ,Days_overdue__c from Credit_Control__c where Dispute__c =: mapCase.keySet()] ){
                mapCaseIdCredit.put(cobj.Dispute__c, cobj);
            }
            
            for(Case eachcase : listAllDisputedCase){
                enddate = null;
                startdate = null;
                
                For(CaseHistory caseHistory : eachcase.Histories){
                    system.debug('--caseHistory--> '+caseHistory);
                    if(caseHistory.OldValue == 'Evidence gathering agent/landlord'){
                        enddate = caseHistory.CreatedDate;
                    }
                    
                    if(caseHistory.NewValue == 'Evidence gathering agent/landlord'){
                        startdate = caseHistory.CreatedDate;
                    }
                    
                    if(startdate != null && enddate != null){
                        break;
                    }                    
                }
                
                overduedays = 0;
                if(startdate != null && enddate != null ){  
                    // noofDays = Date.valueOf(startdate).daysBetween(Date.valueOf(enddate));
                    noofDays = daysBetweenExcludingWeekends(startdate,enddate);
                    system.debug('Overdue case--> '+noofDays);
                    if(noofDays > 11){
                        overduedays = noofDays - 11;
                    }
                    system.debug('Overdue days--> '+overduedays);
                    cc = mapCaseIdCredit.get(eachcase.Id);
                    cc.Days_overdue__c = overduedays;
                    updatecreditlist.add(cc);  
                }  
            }
            
            system.debug('-104-'+creditlist);
            system.debug('-105-'+overduedays);
            system.debug('--113'+updatecreditlist.size());
            database.update(updatecreditlist,false);
            system.debug('--115'+updatecreditlist);
        }
        catch(DmlException ex){
            Insert (new Error_Log__c(Message_Long__c='Issue is: '
                                     + ex.getMessage() + '************ StackTrace String : ' + ex.getStackTraceString()
                                     + ' at Line Number- ' + ex.getLineNumber(),Method_Name__c='Class: EI_EWI_CalOverdueBatch '));
        }  
    }
    
    
    
    global void finish(Database.BatchableContext BC) {  
        
    } 
    
    public static Integer daysBetweenExcludingWeekends(Datetime startDate, Datetime endDate) {
        Integer i = 0;
        
        while (startDate < endDate) {
            if (startDate.format('EEE') != 'Sat' && startDate.format('EEE') != 'Sun') {
                i = i + 1;
            }
            startDate = startDate.addDays(1);
        }
        
        return i;
    }
    public static Integer daysBetweenExcludingWeekends1(Datetime startDate, Datetime endDate) {
        Integer i = 0;
        
        while (startDate < endDate) {
            if (startDate.format('EEE') != 'Sat' && startDate.format('EEE') != 'Sun') {
                i = i + 1;
            }
            startDate = startDate.addDays(1);
        }
        
        return i;
    }
    public static Integer daysBetweenExcludingWeekends2(Datetime startDate, Datetime endDate) {
        Integer i = 0;
        
        while (startDate < endDate) {
            if (startDate.format('EEE') != 'Sat' && startDate.format('EEE') != 'Sun') {
                i = i + 1;
            }
            startDate = startDate.addDays(1);
        }
        
        return i;
    }
    public static Integer daysBetweenExcludingWeekends3(Datetime startDate, Datetime endDate) {
        Integer i = 0;
        
        while (startDate < endDate) {
            if (startDate.format('EEE') != 'Sat' && startDate.format('EEE') != 'Sun') {
                i = i + 1;
            }
            startDate = startDate.addDays(1);
        }
        
        return i;
    }
    public static Integer daysBetweenExcludingWeekends4(Datetime startDate, Datetime endDate) {
        Integer i = 0;
        
        while (startDate < endDate) {
            if (startDate.format('EEE') != 'Sat' && startDate.format('EEE') != 'Sun') {
                i = i + 1;
            }
            startDate = startDate.addDays(1);
        }
        
        return i;
    }
    public static Integer daysBetweenExcludingWeekends5(Datetime startDate, Datetime endDate) {
        Integer i = 0;
        
        while (startDate < endDate) {
            if (startDate.format('EEE') != 'Sat' && startDate.format('EEE') != 'Sun') {
                i = i + 1;
            }
            startDate = startDate.addDays(1);
        }
        
        return i;
    }
    
    
}