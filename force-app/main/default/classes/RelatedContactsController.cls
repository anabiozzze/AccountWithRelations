public with sharing class RelatedContactsController{ 


    // Class gets a list of all profile contacts with two custom fields (already added to them from Lightning Exp) - 
    // 'Relations__c' and 'RelationRole__c'. Fields are responsible for displaying 'Direct \ Indirect' information and roles for related contacts.
    // Methods sequentially fill out these fields for each contact, and then remove from the list all contacts that are not related.
    
    @TestVisible public static List<Contact> contacts = new List<Contact>();
    
    //main method - getiing all contacts, adding Direct & Roles fields and removing non-related contacts from result list
    public RelatedContactsController(){
    }

    @AuraEnabled(cacheable=true)
    public static List<Contact> getContacts() {
        pullContacts();
        addDirect(); 
        addRoles();
        selectRelated();
        return contacts;
    }

    @AuraEnabled(cacheable=true)
    public static List<Contact> pullContacts(){ 
        //The request forms a contact list, collecting all main fields + two custom (empty yet) + list of roles.   
        contacts = [SELECT Id, Name, Account.Name, Account.Id, Title, Email, Phone, Contact.Relations__c, Contact.RelationRole__c, 
                    (SELECT Roles, IsDirect FROM AccountContactRelations) FROM Contact LIMIT 1000];
        return contacts;             
    }
    

    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts(){ 
        //The request forms a account list for the drop-down menu on the page
        List<Account> result = [SELECT Id, Name, Industry, MasterRecordId, Site FROM Account LIMIT 1000];
        return result;             
    }

    //method binds the 'RelationRole__c' field of all contacts in the list to the Relation Roles from ACR.
    @TestVisible private static void addRoles(){
        try {  
            for(Contact con: contacts){             
                for (AccountContactRelation acr: con.AccountContactRelations) {         
                     
                    if (!acr.isDirect) {
                        con.RelationRole__c = acr.Roles;
                        
                        } 
                    
                    //Necessary for a timely interruption of the cycle and the correct recording of roles on all contacts. 
                    if (con.RelationRole__c !=null && con.RelationRole__c!='') break;
                }  
            }  
        } catch(NullPointerException e) {System.debug('The contacts is null at addRoles: ' + e.getMessage());}  
    }
    
    
    //method binds the 'Relations__c' field of all contacts in the list to the value of isDirect, translating it into String.
    @TestVisible private static void addDirect(){ 
        try {
            for(Contact con: contacts){             
                for (AccountContactRelation acr: con.AccountContactRelations) {         
                    
                    if (acr.isDirect) {con.Relations__c = 'Direct';}
                    else con.Relations__c = 'Indirect';           
                    
                    //Necessary for a timely interruption of the cycle and the correct recording of roles on all contacts.
                    if (con.Relations__c!=null && con.Relations__c!='') break;     
                }  
            }
        } catch(NullPointerException e) {System.debug('The contacts is null at showDirect: ' + e.getMessage());}
    }
    
    
    //method selects only 'Related' contacts from the list - or by account name, or by role.
    public static void selectRelated(){ 
        for(integer i=0; i<contacts.size(); i++){
            //Recursion is required to clear the list 100% from other contacts.
            if (contacts.get(i).Account.Name!='N7' && contacts.get(i).RelationRole__c==null) {contacts.remove(i); selectRelated();} //      
        }
    }
}