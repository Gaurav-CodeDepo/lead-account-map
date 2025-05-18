trigger LeadTrigger on Lead (before insert) {
    if(trigger.isBefore && trigger.isInsert){
        LeadTriggerhandler.beforeInsert(trigger.new);
    }

}