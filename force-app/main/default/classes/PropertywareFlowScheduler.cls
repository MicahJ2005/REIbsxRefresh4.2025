public class PropertywareFlowScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
		runFlow();
    }
    
    @future(callout=true)
    public static void runFlow(){
        Flow.Interview myFlow = Flow.Interview.createInterview('Propertyware_Integration', new Map<String, Object>());
        myFlow.start();
    }
}