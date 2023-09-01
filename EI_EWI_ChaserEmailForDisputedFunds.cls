/**********************************************************************************************************
* Author: Himanshi Bhoria
* Purpose: To send emails on when the case status is Consent to TDS resolution not given and checkbox Disputed 
Funds Received is true(No Monies is allocated to the case) Batch for EID 30 AC 6.1
*          
* *******************************************************************************************************/
/* Changes: 
* 
* *******************************************************************************************************/

global class EI_EWI_ChaserEmailForDisputedFunds implements Database.Batchable<sObject>,database.AllowsCallouts, Database.Stateful {
    
    //to get the case recordTypeId
    Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute EW Insured').getRecordTypeId();
    public EI_MailJetUtilityHelper helper = new EI_MailJetUtilityHelper();
    Public Map<Id, Case> caseMap = new Map<Id, Case>();
    Public Map<Id, String> keyMap = new Map<Id, String>();
    
    global DataBase.QueryLocator start(DataBase.BatchableContext BC){        
        String query ='select Id,Status,Respond_date__c,OwnerId,Disputed_Funds_Received__c, Stop_chaser_e_mails__c,'
           + 'Consent_withdrawn_date__c,Evidence_of_court_action_received__c,Dispute_Reference__c,Previous_owner__c,AGLL_Respond_Evidance_Gathering__c,'
           + 'TT_respond_evidence_gathering__c,Counter__c,Deposit_Account_Number__r.Property_Address_WO_Country__c from Case where Respond_date__c !=null '
            + 'AND  RecordtypeId=:devRecordTypeId ' ; // AND ID = \'5003L000005OlHj\'
        return DataBase.getQueryLocator(query);       
        
    }
    
    global void execute(DataBase.BatchableContext BC,List<Case> caseList){
        
        Set<Id> setCaseIds = new Set<Id>();
        List<Case> listAllDisputedCase= new List<Case>();
        // CaseList is not Empty
        try{
            if(!caseList.isEmpty()){
                for(Case objCase : caseList){
                    setCaseIds.add(objCase.Id);
                    
                }
                
                listAllDisputedCase=[select Id,Status,Respond_date__c,OwnerId,Disputed_Funds_Received__c, Stop_chaser_e_mails__c, Consent_withdrawn_date__c,Evidence_of_court_action_received__c,Dispute_Reference__c,Previous_owner__c,AGLL_Respond_Evidance_Gathering__c,TT_respond_evidence_gathering__c,Counter__c,Deposit_Account_Number__r.Property_Address_WO_Country__c, 
                                     (select Id,Type__c, Case__c,Account__c, Account__r.Name, Account__r.Email__c, Account__r.PersonEmail, Contact__c,Case__r.Amount_to_tenants__c, Contact__r.Email, Contact__r.Name, Access_Code__c From Case_Participants__r) from Case where Respond_date__c !=null AND  RecordtypeId=:devRecordTypeId  AND Id=:setCaseIds ];
                for(Case eachCase: listAllDisputedCase){
                    
                    //Status is Consent to TDS resolution not given and No monies is allocated to the case
                    if(eachCase.Status == 'Consent to resolution not given' && eachCase.Stop_chaser_e_mails__c == false){
                        caseMap.put(eachCase.Id, eachCase);
                        keyMap.put(eachCase.Id, 'EID30ChaserEmail');
                    }
                } 
            }
        } 
        catch(DmlException ex){
            Insert (new Error_Log__c(Message_Long__c='Issue is: '
                                     + ex.getMessage() + '************ StackTrace String : ' + ex.getStackTraceString()
                                     + ' at Line Number- ' + ex.getLineNumber(),Method_Name__c='Class: EI_EWI_ChaserEmailForDisputedFunds '));
            
        }
        
    }
    
    
    
    
    global void finish(DataBase.BatchableContext BC){
        EI_MailJetUtilityHelper.MailJetWrapper wrapper = new EI_MailJetUtilityHelper.MailJetWrapper();
        wrapper.keyMap = keyMap;
        wrapper.newMap = caseMap;
        helper.sendMailJetEmail(wrapper);
        
    }
    
}