# Introducing The Cajun Navy Response System

This work is inspired by, and principally based on [Emergency Response Demo](https://erdemo.io).  For a working application, follow that link.

I am doing this re-write for my own education, and to test different combinations of code assistant and LLM.

We'll be using OpenShift as our cloud platform and the Quarkus Java framework for coding.

But, first things first.  Let's talk about our Domains and establish a common domain vocabulary.

We're going to establish our high level domain vocabulary through an interview style conversation, with questions which result in answers that define a vocabulary word for our Domains.

This application is implementing a fictional system based on the coordination of rescue operations loosely termed the Cajun Navy: [https://en.wikipedia.org/wiki/Cajun_Navy](https://en.wikipedia.org/wiki/Cajun_Navy).  It's origins go back to Hurricane Katrina in 2005.

The scenario is that a flood disaster of some sort has occurred and volunteer resources with boats are needed to carry out immediate rescue operations.

## Defining our Domain Vocabulary

Why are we here?  Because a Disaster has occurred, and people need to be rescued.

__Question__: What is a disaster?

__Answer__: A disaster is an event that significantly disrupts the normal operations for a locality.  Now, the locality can be pretty narrow.  For example, your basement...  The washing machine overflows and your sump pump failed.  That's a pretty significant disruption, but not one that is likely to require the attention of the Cajun Navy.  So, let's define locality a bit more broadly.  In our case, a locality represents a population on the order of a town, city, or one or more counties, which may span one or more States.  For simplicity, the examples here will be US centric.

__Domain Vocabulary__: A `Disaster` is an event that significantly disrupts the normal operations for a population on the order of a town, city, or one or more counties, which may span one or more States.  In the case of this application, the `Disaster` is a flood.

__Question__: What do we need to do in order to deal with the disaster, in the immediate term?

__Answer__: Get the affected people to safety.

OK. So, let's focus on that.

__Domain Vocabulary__: Let's call the affected people, `Victims`.

__Question__: What defines a `Victim`?

__Answer__: A `Victim` is an individual who is unable to extricate themselves from a dangerous situation caused by a `Disaster`.

OK, so the goal of our application is to help get `Victims` of a `Disaster` out of danger and to a place of safety.

__Question__: What is a place of safety?

__Answer__: A place of safety is a location that mitigates the immediate effects of the disaster.

__Domain Vocabulary__: Let's call the places of safety `Shelters`.

__Question__: How will we get `Victims` from where they are to a `Shelter`?

__Answer__: We need someone with the appropriate resources and skills to move them.

__Domain Vocabulary__: Let's call the `Victim` movers, `Responders`.

__Question__: How will the `Responders` know how to find `Victims` to move?

__Answer__: `Victims` in close proximity should be handled as a unit of work so that `Responders` can move them efficiently.

__Domain Vocabulary__: Let's call the units of work, `Incidents`.

__Question__: How will the `Responders` know what `Shelter` they should take to take the `Victims` associated with an `Incident` to?

__Answer__: A `Shelter` will be designated for the `Victims` of a given `Incident`, and a link between the `Incident` and the `Shelter` will be provided to the `Responder`.

__Domain Vocabulary__: Let's call the link from `Incident` to `Shelter`, a `Mission`.

__Question__: How do we define the area impacted by a `Disaster`?

__Answer__:  The area of impact will be determined by a contiguous geographic zone which encompasses all of the `Victims` and `Shelters` which can be managed by a regional grouping of `Responders`.  It is possible for a single `Disaster` to have multiple, geographically separated impact areas with their own `Shelters`, `Victims`, and `Responders`

__Domain Vocabulary__: Let's call the area of impact an `Impact Zone`

OK...  let's pause for a minute and analyze our domain vocabulary.  So far, we have:

| Domain Vocabulary | Description |
| --- | --- |
| `Disaster` | An event that significantly disrupts the normal operations for a population on the order of a town, city, or one or more counties, which may span one or more States. |
| `Victim` | An individual who is unable to extricate themselves from a dangerous situation caused by a `Disaster` |
| `Shelter` | A location that mitigates the immediate effects of the disaster |
| `Responder` | Someone with the appropriate resources and skills to move `Victims` to `Shelters` |
| `Incident` | A group of one or more `Victims` who are in close proximity to be handled as a unit of work |
| `Mission` | The link between `Incident` to `Shelter` |
| `Impact Zone` | A geographical area with `Shelters` and `Responders` who can help `Victims` within the boundaries of the zone |

The goal of this operation is for `Responders` to complete `Missions` which move the `Victims` of a `Disaster` from `Incidents` to `Shelters` within a given `Impact Zone`.

Let's build an app to help realize that goal.

## The Domain Activities:

1. Register a `Disaster` with at least one `Impact Zone`.

   The `Impact Zones` indicate the geographical boundaries for operation within the domain.

1. Register one or more `Shelters` associated with an `Impact Zone`.

   The `Shelters` within an `Impact Zone` are the locations of safety that `Responders` will transport `Victims` to.

1. Register `Victims` for assistance.

   One or more `Victims` are grouped into an `Incident` that a `Responder` will retrieve and transport to a `Shelter` in order to complete a `Mission`

1. `Responders` indicate their availability to help `Victims`

1. `Incidents` are created for one or more `Victims` that are in close proximity.

1. An appropriate `Shelter` is identified to accept the `Victims` associated with an `Incident`

1. Create a `Mission` and assign one or more `Incidents` to a `Shelter`

1. Assign a `Mission` to a `Responder`

1. A `Responder` accepts a `Mission`

1. A `Responder` completes a `Mission` by traveling to the location of the `Incident`, retrieving the `Victims`, and moving them to the assigned `Shelter`

## The Domain Aggregates.  

These will be the microservices that we will build.

### Disaster

The `Disaster` aggregate defines the geographical boundaries of the area affected by a disaster.  

A `Disaster` has the following entities:

| Entity | Description |
| --- | --- |
| `Disaster` | A record of the active `Disasters` |
| `Impact Zone` | A geographical region associated with a `Disaster` where `Incidents` are likely to be registered |
| `Victim` | An individual impacted by the disaster and in need of rescue |
| `Incident` | A grouping of one or more `Victims` |
| `Responder` | A rescue team with the skills and resources to rescue `Victims` |

The `Disaster` aggregate will have API endpoints for the management of `Disasters` and their related `Impact Zones`

### Shelter

The `Shelter` aggregate manages the locations of safety and shelter that serve an `Impact Zone` associated with a `Disaster`

The `Shelter` aggregate has the following entities:

| Entity | Description |
| --- | --- |
| `Shelter` | A facility that can accept `Victims` |
| `Victim`  | An individual assigned to the `Shelter` |

### Mission

The `Mission` aggregate manages the rescue operations of `Responders` transporting `Victims` to `Shelters`

The `Mission` aggregate has the following entities:

| Entity | Description |
| --- | --- |
| `Mission` | A `Mission` is an `Incident` associated with a Shelter.  The `Victims` associated with the `Incident` will be transported to the `Shelter` by a `Responder` |
| `Incident`| An `Incident` is the group of `Victims` that the `Responder` will manage as a unit of work|
| `Victim`  | An individual that is grouped as part of an `Incident` assigned to a `Mission` |
| `Shelter` | The destination for all `Victims` associated with an `Incident` |



