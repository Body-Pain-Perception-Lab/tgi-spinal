# Authors: Francesca Fardo <francesca@cfin.au.dk>, Thea Rolskov Sloth, Signe Kirk Brødbæk
import datetime as dt
import pyglet #redundant?
from psychopy import prefs
prefs.general['audioLib'] = ['PTB']
from psychopy import event, visual, core, gui, sound #gui redundant?
import pandas as pd
import random
import numpy as np

import tcs_functions as tcs

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

def run_qst(parameters,threshold_ntrials,tsl_ntrials,save,name,baseline,targetT,iti):
    messageInstruction(parameters, parameters['texts']['textInstruction'][name])
    threshold = []
    ser = tcs.setSerial(parameters) # open serial port
    if name[0:3] in ['CDT','WDT','CPT','HPT']:
        timepoint = 0
        filename = name + '_'+ parameters['lidocaine_timepoint'] + '_' + parameters['arm']
        filenameInfo = tcs.getFilenameInfo(parameters, filename)
        tcs_df = pd.DataFrame({}) 
        timer = core.Clock() # start timer
        for n in range(threshold_ntrials):
            messageParticipantAndExperimenter(parameters, (name + str(n+1)), parameters['texts']['+'])
            trial_n = n + 1
            timepoint, threshold_value, tcs_df = tcs.threshold(parameters, ser, timepoint, timer, baseline, targetT, trial_n, save, filenameInfo, tcs_df) # run threshold
            threshold.extend([threshold_value]) # vector of threshold values
            text_threshold = name + str(n+1) + ': ' + str(round(threshold[n],2)) # text to display after each button press
            messageParticipantAndExperimenter(parameters, text_threshold, parameters['texts']['textBp']) # display
            core.wait(2) # display
            messageParticipantAndExperimenter(parameters, text_threshold, parameters['texts']['+']) # display
            core.wait(iti[0]-2) # iti
    elif name in ['TSL1', 'TSL1_demo']:
        save, bp = True, True
        timepoint, button_press = 0, 0
        tcs_df = pd.DataFrame({}) # initialize data frame to store data  
        tsl_value = 32 # startT
        endT = [50,0,50,0,50,0]
        filename = name + '_'+ parameters['lidocaine_timepoint'] + '_' + parameters['arm']
        filenameInfo = tcs.getFilenameInfo(parameters, filename)
        messageParticipantAndExperimenter(parameters, 'TSL1', parameters['texts']['+'])
        timer = core.Clock() # start timer
        for trial_n in range(tsl_ntrials):
            i = trial_n
            timepoint, tsl_value, tcs_df = tcs.limen(parameters, ser, timepoint, timer, tsl_value, endT[i], trial_n, save, filenameInfo, tcs_df, bp)
            threshold.extend([tsl_value])
            text_threshold = name + '_' + str(i + 1) + ': ' + str(round(threshold[i],2))
            messageParticipantAndExperimenter(parameters, text_threshold, parameters['texts']['textBp'])
            messageParticipantAndExperimenter(parameters, text_threshold, parameters['texts']['+']) # otherwise the text will stay on for the entire duration of the TSL
        trial_vector = [i for i in range(tsl_ntrials) if i%2 == 0]
        threshold = [threshold[t]-threshold[t+1] for t in trial_vector] # calculate warm-cold difference
        tcs.setBaseline(ser, 32) # change baseline parameter to 32 C
        tcs.writeString(ser,'L') # set baseline to 32 C
        tcs.writeString(ser,'A') 
    tcs.closeSerial(ser) # close serial port
    return threshold

def run_tsl2(parameters, save, name, endT):
    timepoint = 0 #, time_sampled, button_press = 0, 0, 0
    baseline = 32
    filename = name + '_' + parameters['lidocaine_timepoint'] + '_' + parameters['arm']
    filenameInfo = tcs.getFilenameInfo(parameters,filename)
    messageInstruction(parameters, parameters['texts']['textInstruction'][name])
    messageParticipantAndExperimenter(parameters, 'TSL2', parameters['texts']['+'])
    ser = tcs.setSerial(parameters) # open serial port
    text_threshold = "" # added 14042021
    tcs_df = pd.DataFrame({}) # initialize data frame to store data  
    timer = core.Clock() # start timer
    for trial_n in range(len(endT)):
        i = trial_n
        messageParticipantAndExperimenter(parameters, text_threshold, parameters['texts']['+']) # added 14042021
        if (i % 2) == 0: # if odd number, fixed target temperature without button press
            if endT[i] is 32: 
                durationT = np.mean([abs(float(parameters['TGIwarm'])-32),abs(float(parameters['TGIcold'])-32)])   
                timepoint, tsl_value, tcs_df = tcs.baseline(parameters, ser, timepoint, timer, baseline, durationT, trial_n, save, filenameInfo, tcs_df, bp = False)
            else: 
                timepoint, tsl_value, tcs_df = tcs.limen(parameters, ser, timepoint, timer, baseline, endT[i], trial_n, save, filenameInfo, tcs_df, bp = False)
                text_threshold = 'target' + str(i+1) + ': ' + str(round(endT[i],2))
        elif not (i % 2) == 0: # if even number, fixed target temperature with button press
            bp_time = round(timer.getTime(),2)
            tcsData = [timepoint, trial_n, bp_time, tsl_value, tsl_value, tsl_value, tsl_value, tsl_value, 2]
            tcs_df = tcs.saveTcsData(parameters, tcsData, filenameInfo, tcs_df) # save beep time 
            cue = sound.Sound('beep-07.wav')
            cue.play() 
            core.wait(0.11)
            cue.stop()
            if endT[i] > 32: # warming
                timepoint, tsl_value, tcs_df = tcs.limen(parameters, ser, timepoint, timer, 32, endT[i], trial_n, save, filenameInfo, tcs_df, bp = True) # change temperature until a button press
                startT = tsl_value
            elif endT[i] < 32: # cooling
                timepoint, tsl_value, tcs_df = tcs.limen(parameters, ser, timepoint, timer, 32, endT[i], trial_n, save, filenameInfo, tcs_df, bp = True) # change temperature until a button press
                startT = tsl_value
            text_threshold = name + '_' + str(i+1) + ': ' + str(round(startT,2))
            messageParticipantAndExperimenter(parameters, text_threshold, parameters['texts']['textBp']) #textBp instead of + # added 14042021
            timepoint, tsl_value, tcs_df = tcs.limen(parameters, ser, timepoint, timer, tsl_value, baseline, trial_n, save, filenameInfo, tcs_df, bp = False) # return to baseline
            core.wait(abs(tsl_value-32)) # wait until the temperature is back to baseline and then abort
            tcs.writeString(ser,'A') # abort stimulation
    tcs.setBaseline(ser, 32) # change baseline parameter to 32 C
    tcs.writeString(ser,'L') # set baseline to 32 C
    tcs.writeString(ser,'A') # abort stimulation
    tcs.closeSerial(ser)
        
def run_tgi(parameters, targetT, trial_n, filenameInfo, tgi_df):
    #messageWait(parameters) ### wait for space press to continue ###
    messageInstruction(parameters, str(parameters['texts']['textNext']+parameters['texts']['textNextTGI']))
    messageParticipantAndExperimenter(parameters, 'TGI', parameters['texts']['+'])
    ser = tcs.setSerial(parameters) # open serial port
    tcs.tgi(ser, targetT) # stimulate
    cue = sound.Sound('beep-07.wav')
    cue.play()
    #core.wait(0.11)
    #cue.stop()
    core.wait(3)
    tcs.closeSerial(ser) # close serial port
    #################
    # Descriptors
    #################
    des_pressed, des_time = descriptors(parameters)
    tgiData = [trial_n, des_time, 'descriptors', des_pressed, targetT] # update tgi data with descriptor results
    tgi_df = tcs.saveTgiData(parameters, tgiData, filenameInfo, tgi_df) # save results
    #################
    # VAS 
    #################
    vas = ['pain', 'unpleasantness', 'cold', 'warm']
    random.shuffle(vas)
    for i in range(len(vas)):
        rating_value, vas_time = vasRatingScale(parameters, vas[i]) # present rating scale
        chosen_rating = str(vas[i]) + '_' + 'chosen rating value: ' + str(rating_value) 
        messageParticipantAndExperimenter(parameters, chosen_rating, parameters['texts']['+']) #display to experimenter what the participant chooses on the VAS
        tgiData = [trial_n, vas_time, vas[i], rating_value, targetT] # update tgi data with rating results
        tgi_df = tcs.saveTgiData(parameters, tgiData, filenameInfo, tgi_df) # save results
    return tgi_df

def run(parameters, win=None):
    # Define window
    if win is None:
        win = parameters['win1']

    ###############
    # DEMO: QST
    ###############
    if parameters['runDemoQST'] is True:
        messageInstruction(parameters, parameters['texts']['textInstruction']['QST'])
        qst_measures = ['CDT_demo', 'WDT_demo', 'TSL1_demo', 'CPT_demo', 'HPT_demo'] # define vector of measures
        base = [32]*5
        temp = [[0]*5, [50]*5, [0]*5, [0]*5, [50]*5]# define vector of target temperatures
        iti = [2]*2 + [0] + [2]*2 # define vector of ITIs (i.e., time in between each threshold repetition)
        for q in range(len(qst_measures)): 
            threshold = run_qst(parameters, threshold_ntrials = 1, tsl_ntrials = 4, save = True, name = qst_measures[q], baseline = base[q], targetT = temp[q], iti = [iti[q]]*5)
        messageParticipantAndExperimenter(parameters, parameters['texts']['textEnd'], parameters['texts']['textEnd'])
        core.wait(2)

    ###############
    # QST
    ###############
    if parameters['runQST'] is True:
        messageInstruction(parameters, parameters['texts']['textInstruction']['QST'])
        qst_measures = parameters['qst_sequence']
        for q in range(len(qst_measures)): 
            threshold_ntrials = 3
            tsl_ntrials = 6
            save = True
            name = parameters['qst_sequence'][q]
            baseline = parameters[name]['base']
            targetT = parameters[name]['targetT']
            iti = parameters[name]['iti']
            threshold = run_qst(parameters, threshold_ntrials, tsl_ntrials, save, name, baseline, targetT, iti) # stimulate
            avg = round(np.nanmean(threshold),2) # calculate the average threshold
            messageParticipantAndExperimenter(parameters, 'AVG ' + qst_measures[q] + ": " + str(round(avg,2)), parameters['texts']['+'])
            core.wait(3) # display average
            #################
            #  Save ratings in summary df
            #################
            parameters['qst_df']  = parameters['qst_df'].append([
            pd.DataFrame({'subject_n': parameters['subject_n'], 
                    'lidocaine_timepoint': parameters['lidocaine_timepoint'], 
                    'arm': [parameters['arm']], 
                    'task': [qst_measures[q]],
                    'threshold': [round(avg,2)]
                    })], ignore_index=True)
            parameters['qst_df'].to_csv(parameters['qst_filename'], index=False) 
        messageParticipantAndExperimenter(parameters, parameters['texts']['textEnd'], parameters['texts']['textEnd'])
        core.wait(2)

    ###############
    # DEMO: TSL2
    ###############
    if parameters['runDemoTSL2'] is True:
        #w = float(parameters['TGIwarm'])
        #c = float(parameters['TGIcold'])
        #b = 32
        for tsl2 in range(len(parameters['tsl_sequence'])):
            messageWait(parameters)
            run_tsl2(parameters, save = True, name = 'TSL2_demo', endT = parameters['tsl_sequence'][tsl2])
        #    all_endT = [b,50,b,0]
        #all_endT = [w,50,w,0]
        #messageWait(parameters)
        #run_tsl2(parameters, save = True, name = 'TSL2_demo', endT = all_endT)
        #all_endT = [c,50,c,0]
        #messageWait(parameters)
        #run_tsl2(parameters, save = True, name = 'TSL2_demo', endT = all_endT)
        messageParticipantAndExperimenter(parameters, parameters['texts']['textEnd'], parameters['texts']['textEnd'])
        core.wait(2)

    ##############
    #   TSL2
    ###############
    if parameters['runTSL2'] is True:
        #w = float(parameters['TGIwarm'])
        #c = float(parameters['TGIcold'])
        #b = 32
        
        for tsl2 in range(len(parameters['tsl_sequence'])):
            messageWait(parameters)
            run_tsl2(parameters, save = True, name = 'TSL2', endT = parameters['tsl_sequence'][tsl2]*3)

#        all_endT = [b,50,b,0]*3        
#        all_endT = [w,50,w,0]*3
#        messageWait(parameters)
#        run_tsl2(parameters, save = True, name = 'TSL2', endT = parameters['tsl_sequence'][tsl2]*3)
#        
#        all_endT = [c,50,c,0]*3
#        messageWait(parameters)
#        run_tsl2(parameters, save = True, name = 'TSL2', endT = all_endT)
#        
        messageParticipantAndExperimenter(parameters, parameters['texts']['textEnd'], parameters['texts']['textEnd'])
        core.wait(2)

    ###############
    # DEMO: TGI
    ###############
    if parameters['runDemoTGI'] is True:
        filename = 'TGI_demo' + '_'+ parameters['lidocaine_timepoint'] + '_' + parameters['arm']
        filenameInfo = tcs.getFilenameInfo(parameters, filename) # define full path
        messageInstruction(parameters, parameters['texts']['textInstruction']['TGI_demo'])
        tgi_df = pd.DataFrame({}) # initialize data frame to store data  
        targetT = [random.choice(parameters['tgi_stimuli']['nonTGIcold']), random.choice(parameters['tgi_stimuli']['nonTGIwarm']), parameters['tgi_stimuli']['TGI']]
        for n in range(len(targetT)):
            tgi_df = run_tgi(parameters,targetT[n], n, filenameInfo, tgi_df)
        messageParticipantAndExperimenter(parameters, parameters['texts']['textEnd'], parameters['texts']['textEnd'])
        core.wait(2)

    ###############
    #   TGI
    ###############
    if parameters['runTGI'] is True:
        filename = 'TGI' + '_'+ parameters['lidocaine_timepoint'] + '_' + parameters['arm']
        filenameInfo = tcs.getFilenameInfo(parameters, filename) # define full path
        messageInstruction(parameters, parameters['texts']['textInstruction']['TGI'])
        tgi_df = pd.DataFrame({}) # initialize data frame to store data  
        k = [0,3,6] # to keep track of the trial number
        for t in range(3): # 9 stimuli in total
            targetT = [random.choice(parameters['tgi_stimuli']['nonTGIcold']), random.choice(parameters['tgi_stimuli']['nonTGIwarm']), parameters['tgi_stimuli']['TGI']]
            random.shuffle(targetT) # shuffle stimulation order
            for n in range(len(targetT)):
                trial_n = n + k[t]
                tgi_df = run_tgi(parameters,targetT[n], trial_n, filenameInfo, tgi_df)
        messageParticipantAndExperimenter(parameters, parameters['texts']['textEnd'], parameters['texts']['textEnd'])
        core.wait(2)

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