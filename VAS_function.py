# Author AG Mitchell 22.02.22, adapted from task_functions.py by Francesca Fardo

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
        
#Display messages
def messageWait(parameters):
    """ Continue to the next task by pressing the space bar
    and display message to participant """
    win0 = parameters['win0']
    win1 = parameters['win1']
    waitText0=visual.TextStim(win0, height=parameters['textSize'], text=parameters['texts']['textContinue'])
    waitText1=visual.TextStim(win1, height=parameters['textSize'], text=parameters['texts']['textNext'])
    waitText0.draw()
    waitText1.draw()
    win1.flip()
    win0.flip()
    quit_exp(parameters)
    event.waitKeys(keyList = parameters['nextTask'])

def messageInstruction(parameters, text):
    win0 = parameters['win0']
    win1 = parameters['win1']
    textInstruction0 = visual.TextStim(win0, height=parameters['textSize'], text = (text + "\n \n Tryk SPACE for at begynde"))
    textInstruction1 = visual.TextStim(win1, height=parameters['textSize'], text = text)
    textInstruction0.draw()
    textInstruction1.draw()
    win0.flip()
    win1.flip()
    #quit_exp(parameters) #redundant?
    event.waitKeys(keyList=parameters['nextTask'])
    
def messageParticipantAndExperimenter(parameters, text0, text1):
    win0 = parameters['win0']
    win1 = parameters['win1']
    text0 = visual.TextStim(win0, height=parameters['textSize'], text = text0)
    text1 = visual.TextStim(win1, height=parameters['textSize'], text = text1)
    text0.draw()
    text1.draw()
    win0.flip()
    win1.flip()
        
vas = ['pain', 'unpleasantness', 'cold', 'warm']
random.shuffle(vas)
        
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

def descriptors(parameters, win=None):
    # Define window
    if win is None:
        win = parameters['win1']

    #Define mouse
    mouse = event.Mouse(visible=True,win=win,newPos=[0,0]) ## Mouse start at the center ##

    # Randomize descriptor positions
    des_pos = [(-0.4,0.4),(-0.4,0),(-0.4,-0.4),(0.4,0.4),(0.4,0),(0.4,-0.4)]
    random.shuffle(des_pos)

    #Define descriptors
    burn = visual.TextStim(win,
        pos = des_pos[0], 
        height = parameters['vasParameters']['height'], 
        text = parameters['descriptors']['text']['burn'])
    burn_rect = visual.rect.Rect(win, lineColor = 'white',
        pos = des_pos[0],
        height = parameters['descriptors']['rectHeight'])

    warm = visual.TextStim(win,
        pos = des_pos[1], 
        height = parameters['vasParameters']['height'], 
        text = parameters['descriptors']['text']['warm'])
    warm_rect = visual.rect.Rect(win,lineColor = 'white',
        pos = des_pos[1], 
        height = parameters['descriptors']['rectHeight'])

    neutral = visual.TextStim(win,
        pos = des_pos[2], 
        height = parameters['vasParameters']['height'], 
        text = parameters['descriptors']['text']['neutral'])
    neutral_rect = visual.rect.Rect(win, lineColor = 'white',
        pos = des_pos[2], 
        height=parameters['descriptors']['rectHeight'])

    cold = visual.TextStim(win,
        pos = des_pos[3], 
        height = parameters['vasParameters']['height'], 
        text = parameters['descriptors']['text']['cold'])
    cold_rect = visual.rect.Rect(win, lineColor = 'white',
        pos = des_pos[3], 
        height = parameters['descriptors']['rectHeight'])

    freez = visual.TextStim(win,
        pos = des_pos[4], 
        height = parameters['vasParameters']['height'], 
        text = parameters['descriptors']['text']['freez'])
    freez_rect = visual.rect.Rect(win, lineColor = 'white',
        pos = des_pos[4], 
        height=parameters['descriptors']['rectHeight'])

    other = visual.TextStim(win,
        pos = des_pos[5], 
        height = parameters['vasParameters']['height'], 
        text = parameters['descriptors']['text']['other'])
    other_rect = visual.rect.Rect(win, lineColor = 'white',
        pos = des_pos[5], 
        height = parameters['descriptors']['rectHeight'])

    intro = visual.TextStim(win,
        pos = parameters['descriptors']['pos']['intro'],
        height = parameters['vasParameters']['height'], 
        text = parameters['descriptors']['text']['intro'])

    outro = visual.TextStim(win,
        pos = parameters['descriptors']['pos']['outro'],
        height = parameters['vasParameters']['height'], 
        text = parameters['descriptors']['text']['outro'])
    outro_rect = visual.rect.Rect(win, lineColor = 'white',
        pos = parameters['descriptors']['pos']['outro'], 
        height=parameters['descriptors']['rectHeight'],
        width=parameters['descriptors']['rectWidth'])

    des_texts = [burn, warm, neutral, cold, freez, other]    
    des_texts_pressed = ["burn", "warm", "neutral", "cold", "freez", "other"]
    des_rects = [burn_rect,warm_rect,neutral_rect,cold_rect,freez_rect, other_rect]
    
    # create empty result frame called des_pressed
    des_pressed=[]
    # reset timer
    timer.reset()
    
    while True:
        quit_exp(parameters) # quit with 'q'
        intro.draw()
        outro.draw()
        outro_rect.draw()
        for i in range(6):
            des_texts[i].draw()
            des_rects[i].draw()
        for i in range(6):
            if mouse.isPressedIn(des_rects[i]):
                if des_rects[i].lineColor is not "gold":
                    des_texts[i].color = "gold"
                    des_rects[i].lineColor = "gold"
                    if des_texts_pressed[i] not in des_pressed:
                        des_pressed += [des_texts_pressed[i]]
                elif des_rects[i].lineColor is "gold":
                    des_texts[i].color = 'white'
                    des_rects[i].lineColor ='white'
                    des_pressed.remove(des_texts_pressed[i])
                core.wait(0.1)
        win.flip()
        if mouse.isPressedIn(outro_rect) or event.getKeys(keyList ='space'): # press within outro_rect to break the loop #mouse.getPressed()[2]: # right click breaks the loop
            des_time = round(timer.getTime(),2)
            break
    return des_pressed, des_time