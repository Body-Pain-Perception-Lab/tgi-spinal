# Author AG Mitchell 22.02.22, adapted from task_functions.py by Francesca Fardo

import datetime as dt

from psychopy import prefs
prefs.general['audioLib'] = ['PTB']
from psychopy import event, visual, core, gui, sound #gui redundant?

#Define clock
timer = core.Clock()

#Quit experiment by pressing q
def quit_exp(parameters):
    """ Quit experiment by pressing the 'q' key """
    #win = parameters['win1']  # redundant?
    if event.getKeys(keyList=parameters['quit']):
        print ("User exited")
        core.quit()
        
def vasRatingScale(parameters, vas, win=None):
    """Rating scale, using keyboard inputs.
    Parameters
    ----------
    parameters : dict
        Parameters dictionary.
    vas: 'pain', 'unpleasantness', 'cold', 'warm'
    win1 : psychopy window instance for participant - the VAS is shown here
        The window where to show the task.
    """
    # Define window
    if win is None:
        win = parameters['win1']
    
    #Setup pyglet keyboard for slider
    #pyglet_key=pyglet.window.key #redundant?
    #keyboard = pyglet_key.KeyStateHandler() #redundant?
    #parameters['win1'].winHandle.push_handlers(keyboard) #redundant?
     
    # Define parameters for VAS scale
    low = parameters['vasParameters']['low']
    high = parameters['vasParameters']['high']
    increment = parameters['vasParameters']['increment']

    #setup four different ratingscales
    labels = parameters['texts']['textVasAnchors'][vas]
    text = parameters['texts']['textVasTitle'][vas]
    #VAS scale
    vasRatingScale = visual.RatingScale(parameters['win1'], 
                    low = low,
                    high = high ,
                    marker = parameters['vasParameters']['marker'], 
                    markerColor = parameters['vasParameters']['markerColor'], 
                    markerStart = low,
                    tickMarks = parameters['vasParameters']['tickMarks'], 
                    stretch = parameters['vasParameters']['stretch'], 
                    noMouse = parameters['vasParameters']['noMouse'], 
                    tickHeight = parameters['vasParameters']['tickHeight'],
                    labels = labels,
                    leftKeys = 'down',
                    rightKeys = 'up',
                    acceptKeys = 'space',
                    showAccept = parameters['vasParameters']['showAccept'],
                    acceptSize = parameters['vasParameters']['acceptSize'],
                    acceptPreText = parameters['vasParameters']['acceptPreText'],
                    showValue = parameters['vasParameters']['showValue'],
                    acceptText = parameters['vasParameters']['acceptText'],
                    textColor = parameters['vasParameters']['textColor'],
                    textSize = parameters['vasParameters']['textSize'])
    vasText = visual.TextStim(parameters['win1'],
                    pos = parameters['vasParameters']['pos'],
                    height = parameters['vasParameters']['height'], 
                    text = text)
    
    # Response
    rating_value = None
    event.clearEvents()
    #reset timer
    timer.reset()
    while vasRatingScale.noResponse:
        quit_exp(parameters) # press 'q' to quit
#        for events in keyboard: #redundant?
#                if vasRatingScale.markerPlacedAt > high:
#                    vasRatingScale.markerPlacedAt = high # do not allow marker to move outside the scale (above 100)
#                elif vasRatingScale.markerPlacedAt < low:
#                    vasRatingScale.markerPlacedAt = low # do not allow marker to move outside the scale (below 0)
#                if keyboard[pyglet_key.RIGHT]:
#                    vasRatingScale.markerPlacedAt += increment # update "faster" on right key hold
#                elif keyboard[pyglet_key.LEFT]:
#                    vasRatingScale.markerPlacedAt -= increment # update "faster" on left key hold
        vasRatingScale.draw()
        vasText.draw()
        win.flip()
        quit_exp(parameters)
    rating_value = vasRatingScale.getRating()
    vas_time = round(timer.getTime(),2)
    return rating_value, vas_time