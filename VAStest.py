import datetime as dt
import random
import pandas as pd
import numpy as np
from parameters_spinal import getParameters

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

parameters = getParameters(
    subject_n = '1',
    tasks = 'VAS',
    arm = 'A')

def vasRatingScale(parameters, vas, win=None):
    """Rating scale, using keyboard inputs.
    Parameters
    ----------
    parameters : dict
        Parameters dictionary.
    vas: 'pain', 'unpleasantness', 'cold', 'warm'
    win1 : psychopy window instance for participant - the VAS is shown here
        The window where to show the task.
    win0 : experimenters screen
    """
    # Define window
    if win is None:
        win = parameters['win1']
    else: 
        win = visual.Window(screen=0, fullscr=False)

    
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
    vasRatingScale = visual.RatingScale(win, 
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
    vasText = visual.TextStim(win,
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

def messageParticipantAndExperimenter(parameters, text0, text1):
    win0 = parameters['win0']
    win1 = parameters['win1']
    text0 = visual.TextStim(win0, height=parameters['textSize'], text = text0)
    text1 = visual.TextStim(win1, height=parameters['textSize'], text = text1)
    text0.draw()
    text1.draw()
    win0.flip()
    win1.flip()

# Define parameters for VAS scale
#def run_vas(parameters, targetT, trial_n, filenameInfo, tgi_df):
vas = ['pain', 'unpleasantness', 'cold', 'warm']
random.shuffle(vas)
for i in range(len(vas)):
    rating_value, vas_time = vasRatingScale(parameters, vas[i]) # present rating scale
    chosen_rating = str(vas[i]) + '_' + 'chosen rating value: ' + str(rating_value) 
    messageParticipantAndExperimenter(parameters, chosen_rating, parameters['texts']['+']) #display to experimenter what the participant chooses on the VAS
    #tgiData = [trial_n, vas_time, vas[i], rating_value, targetT] # update tgi data with rating results
    #tgi_df = tcs.saveTgiData(parameters, tgiData, filenameInfo, tgi_df) # save results
#return tgi_df