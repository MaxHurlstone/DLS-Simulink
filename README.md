# DLSimulink

Install **DLSimulink**, then type `dlshelp` in the MATLAB command window!

## Status

Under development!

## About

DLSimulink is a MATLAB toolbox that aims to standardise and streamline
engineering analysis at the UK's national synchrotron, [Diamond Light Source](https://www.diamond.ac.uk/Home.html) (DLS).
Some examples of usage/features are: 
- mechatronics/controls simulation setup/analysis scripts
- custom Simscape components
- material thermal property databases. 

DLSimulink was initially developed, and is currently maintained by 
[Max Hurlstone](https://uk.mathworks.com/matlabcentral/profile/authors/38911387), Mechanical Design Engineer at DLS.

## Getting started

### Installation

To install, either head to Add-Ons in MATLAB ("Home" tab, under the "Environment" section), and search for DLSimulink. Click add to MATLAB.

Or, go to the [MATLAB File Exchange](https://www.mathworks.com/matlabcentral/fileexchange/) and search for DLSimulink. 
Click Download -> toolbox. Once downloaded, click the .mltbx file in your downloads. 

### Documentation

Documentation is a work in progress...but for the moment head to the toolbox page in the MATLAB Add-Ons tab. 
The "Functions" tab for the toolbox will list all source code and give an idea of functionality.

## Contributing

The more people willing to contribute to this, the better. Obviously, I hope this
toolbox achieves its goal of standardising and streamlining engineering at DLS. But also,
contributing to the toolbox is a great way to learn proper code development skills, which I didn't have before trying this
(and probably still don't!).

If you are interested in contributing, contact me: **max.hurlstone@diamond.ac.uk** 

### Developing A Feature

I'd recommend looking at some guides for git, such as this [very concise one](https://rogerdudler.github.io/git-guide/). 
I have added a cheat sheet from this page to the git repository for quick access.

### Reviewing A Feature

Ideally all of our features are propery reviewed through Pull Requests. To find out more [click here](https://rogerdudler.github.io/git-guide/).
Due to time constraints, we don't implement all aspects of code development (unit tests, for example). 
Nonetheless, the Pull Request is a useful way to make sure at least another engineer has looked at a new feature,
and confirm that it works well.

### Engineering Drawing Development Analogy

In many ways, the process for developing a function or toolbox feature is the same
as the one followed to get an engineering drawing approved. You: choose a product
to work under (choosing a branch), work on the part and frequently save and upload (git add, commit and push)
, and finally you raise a promotion request to get the drawing added to iDrawings
(creating a pull request to merge code with the main branch). Thinking of code development in this way
might increase your confidence and remove barriers to entry to contribute to this toolbox!

## DLS Confluence Page

**! Only for DLS employees !**

There is a Confluence page: under Engineering Design Guidelines -> DLSimulink. This is also a work in
progress, but it might provide some more useful information.
