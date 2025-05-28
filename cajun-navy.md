# Introducing The Cajun Navy Response System

This work is inspired by, and principally based on [Emergency Response Demo](https://erdemo.io).  For a working application, follow that link.

I am doing this re-write for my own education.  If you want to come along on the journey, we're going to use the principles of Domain Driven Design to create an application that is deployed across three "regions" for maximum resiliency.

Along the way, we'll be using OpenShift as our cloud platform, Cassandra for persistence, Kafka for eventing, and the Quarkus Java framework for coding.

But, first things first.  Let's talk about our Domains and establish a common domain vocabulary.

We're going to establish our high level domain vocabulary through an interview style conversation, with questions which result in answers that define a vocabulary word for our Domains.

## Defining our Domain Vocabulary

Why are we here?  Because a Disaster has occurred, and people need to be rescued.

This application is implementing a fictional system based on the coordination of rescue operations loosely termed the Cajun Navy: [https://en.wikipedia.org/wiki/Cajun_Navy](https://en.wikipedia.org/wiki/Cajun_Navy).  It's origins go back to Hurricane Katrina in 2005.

The scenario is that a flood disaster of some sort has occurred and volunteer resources with boats are needed to carry out immediate rescue operations.

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

## The Domain Processes:

1. Register a `Disaster` with at least one `Impact Zone`.

1. Register one or more `Shelters` associated with an `Impact Zone`.

1. `Victims` are registered for assistance.

1. `Responders` indicate their availability to help `Victims`

1. `Incidents` are created for one or more `Victims` that are in close proximity.

1. An appropriate `Shelter` is identified to accept the `Victims` associated with an `Incident`

1. Create a `Mission` and assign one or more `Incidents` to a `Shelter`

1. Assign a `Mission` to a `Responder`

1. A `Responder` accepts a `Mission`

1. A `Responder` completes a `Mission` by traveling to the location of the `Incident`, retrieving the `Victims`, and moving them to the assigned `Shelter`

## The Domain Aggregates

### Disaster

The `Disaster` aggregate defines the geographical boundaries of the area affected by the disaster.  

`Disaster` maintains a relationship with:

* Impact Zones
* Registered `Shelters`
* Registered `Responders`
* Registered `Victims`

A `Disaster` has the following entities:

| Entity | Description |
| --- | --- |
| `Impact Zone` | A geographical region where `Incidents` are likely to be registered |
| `Shelter` | A facility that can accept `Victims` |
| `Responder` | A rescue team with the skills and resources to rescue `Victims` |
| `Victim` | An individual impacted by the disaster and in need of rescue |