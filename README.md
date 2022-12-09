# TRACR
## Overview

TRACR is an IOS scheduling app designed to automatically schedule users' assignments into evenly distributed tasks based on preferences that have been given by the user

### Key Features:
- **Automated Scheduling** - TRACR creates tasks at times and with lengths that vary according to preferences for working hours and for different assignment types such as essays, presentation, and reports. 
- **Progress** - TRACR displays various metrics and actionable insights, including grades, study patterns, and workload distributions.
- **Google Classroom Integration** - TRACR integrates Google Classroom with the input classes, assignments, and deadlines via the Google Classroom API
- **International Baccleaurate Integration** - For students taking the International Baccleaurate (IB) TRACR displays real IB statistics 

### The Scheduling Algorithm

The app is made up of five main pages: Home, Assignments, Classes, Progress, and Settings. The following sections detail the functionality of each of these pages with a few images.

### Home

This is the page shown when the app is launched. Depending on whether the user wants their tasks to scheduled at specific times or they just want a general checklist of how long to spend on each assignment, this page can be toggled between Specific times and Daiily checklist respectively. The Tasks backlog (top-right button) displays all past incomplete tasks. The user can then select how much of the task they actually completed, and the scheduling algorithms then adjusts the future schedule accordingly. 

|Specific times|Daily checklist|Tasks backlog|
|---|---|---|
|![Simulator Screen Shot - iPhone 12 Pro Max - 2021-07-14 at 20 58 11](https://user-images.githubusercontent.com/46422100/206752337-57e5842c-e572-41b7-9d70-1f3326a71c5e.png)|![simulator_screenshot_3C3CC944-8F13-492D-9F10-6782A18F8FA9](https://user-images.githubusercontent.com/46422100/206752367-aee57588-048e-43b1-98c9-bf24a404b2cd.png)|![simulator_screenshot_ADD47A05-8A06-420E-B144-E0F12D336800](https://user-images.githubusercontent.com/46422100/206752393-0839cb9b-4a37-47c9-b389-68a244409aa4.png)|

### Classes

This page displays all a users' classes and on a class leads to the Specific class page where the assignments for that class both complete and incomplete are displayed. The floating add button in the bottom-right is present in all pages. Tapping it gives three options: add a class, add an assignment, and add a grade. The Add class page is shown below. 

|Classes|Specific class|Add class|
|---|---|---|
|![Simulator Screen Shot - iPhone 12 Pro Max - 2021-07-14 at 22 51 16](https://user-images.githubusercontent.com/46422100/206757622-8154efc4-7316-475e-85e0-9c0b6562473c.png)|![Simulator Screen Shot - iPhone 12 Pro Max - 2021-07-09 at 16 01 10](https://user-images.githubusercontent.com/46422100/206757651-c8457966-e3a5-4dd7-8579-de612799f7ce.png)|![Simulator Screen Shot - iPhone 12 Pro Max - 2021-07-09 at 15 27 08](https://user-images.githubusercontent.com/46422100/206758839-7259454e-f312-4a97-bc16-1f06ec58b8ed.png)|![Uploading Simulator Screen Shot - iPhone 12 Pro Max - 2021-07-09 at 15.27.08.png…]()|

### Assignments

This page displays all the assignments sorted by due date, class, length, name, and type. Tapping an assignment causes it to expand, displaying all the scheduled tasks for the assignment along with more details about the assignment. Tapping the top-right check button toggles the displayed assignments between completed assignments and incomplete assignments. The Add assignment page is shown below.

|Assignments (light mode)|Assignments (dark mode)|Add Assignment|
|---|---|---|
|![Simulator Screen Shot - iPhone 12 Pro Max - 2021-07-09 at 16 00 09](https://user-images.githubusercontent.com/46422100/206762955-703045cc-25ff-4ea1-92ff-e803c6202ae8.png)|![Simulator Screen Shot - iPhone 12 Pro Max - 2021-07-14 at 20 58 21](https://user-images.githubusercontent.com/46422100/206762987-7511d375-6cb1-4b84-932d-018ff8f657c5.png)|![Simulator Screen Shot - iPhone 12 Pro Max - 2021-07-09 at 15 28 09](https://user-images.githubusercontent.com/46422100/206763037-52a8b833-18d2-4fb6-97b9-95172fcd1b6f.png)|

### Progress 

This page displays all a users' grades along with various other insights. The top-most graph shows the users grades for each class over time. The rescheduled tasks circle shows when users have been rescheduling tasks to give an idea of when they are most productive. The workload distribution pie chart shows how the user's workload is distributed between classes. Tapping on a class leads to the Specific Progress for that class where the grades are shown in a bar chart and where additional statistics are shown for IB classes.

|Progress (dark mode)|Progress (light mode)| Specific Progress|
|---|---|---|
|![Simulator Screen Shot - iPhone 12 Pro Max - 2021-07-14 at 20 59 11](https://user-images.githubusercontent.com/46422100/206812527-a8a3c159-e100-452e-804f-3899f1d02fb3.png)|![Simulator Screen Shot - iPhone 12 Pro Max - 2021-07-09 at 15 57 34](https://user-images.githubusercontent.com/46422100/206812549-dbfb98b1-ec90-4558-9cce-dfb2f6e8e9bf.png)|![Simulator Screen Shot - iPhone 11 - 2020-09-27 at 22 14 26](https://user-images.githubusercontent.com/46422100/206813474-8981ad26-d27c-4b1a-a49d-abfd52c527f1.png)|

### Settings

|Settings|Type sliders|Work hours|
|---|---|---|
|![Simulator Screen Shot - iPhone 12 Pro Max - 2021-07-09 at 15 31 39](https://user-images.githubusercontent.com/46422100/206813340-3638a276-4d3c-4419-b9e1-8b86a9824829.png)|![Simulator Screen Shot - iPhone 12 Pro Max - 2021-07-09 at 15 30 54](https://user-images.githubusercontent.com/46422100/206813360-0b614b73-3007-4aee-aa23-339affdca27e.png)|![Simulator Screen Shot - iPhone 12 Pro Max - 2021-07-09 at 15 29 49](https://user-images.githubusercontent.com/46422100/206813386-867962ab-9109-4eb3-8059-d812e278320d.png)|
