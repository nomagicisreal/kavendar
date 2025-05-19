# Kavendar
a dart calendar package.

## Description
the event types in calendar:
1. private personal reminder
2. private personal engaged task
3. protected group workflow (assignment)
4. protected activity (involve the members that already exist)
5. protected/public campaign (with activity(s), need some promotion)

the event holder in calendar:
1. a person
2. an admin in a group (with consensus, without compromise)
3. a delegate in a group (with consensus and compromise)

event collection on:
1. reality tags (event holder, main/sub group, a place...)
2. conceptual tags (see also [the information below](#Conceptual-Tags))

If needed, there is a snapshot for all event collection. it's easy to do some computation, demonstration and more.

## Workflow
TODO:
expectation & estimation, prerequisite & restriction & caution & suggestion
production line: harvest -> loop(n, poster -> demonstration) -> user
process notifications, complete, defer 

## Conceptual Tags
"conceptual tags" is not the enumeration of common usecase, but a complex idea.\
Instead of letting "conceptual tags" as a difficult list tagging on an event,\
every event have only a `TagConceptual` with an bool attribute `focused`,\
indicating the tag itself is a focused tags or not,
which means the event tagged `TagConceptual` should be focused by the user or not.\

TODO:
intent focus / required focus\
there are some built-in conceptual tags for an event:
1. personal goal
2. conscious of responsibility (have joined a group)
3. conscious of participate (not joined but have followed a group)
4. conscious of interest (have subscribed a topic)
5. intent (have joined a group, subscribed a topic)
6. other customized tags