import datetime as dt
import random
import pandas as pd
import numpy as np
from parameters_spinal import getParameters
from VAS_function import vasRatingScale

from psychopy import prefs
prefs.general['audioLib'] = ['PTB']
from psychopy import event, visual, core, gui, sound #gui redundant?

parameters = getParameters(
    subject_n = 1,
    tasks = 'VAS')

# Define parameters for VAS scale
#def run_vas(parameters, targetT, trial_n, filenameInfo, tgi_df):
vas = ['pain', 'unpleasantness', 'cold', 'warm']
random.shuffle(vas)
for i in range(len(vas)):
    rating_value, vas_time = vasRatingScale(parameters, vas[i]) # present rating scale
    chosen_rating = str(vas[i]) + '_' + 'chosen rating value: ' + str(rating_value) 
    messageParticipantAndExperimenter(parameters, chosen_rating, parameters['texts']['+']) #display to experimenter what the participant chooses on the VAS
    tgiData = [trial_n, vas_time, vas[i], rating_value, targetT] # update tgi data with rating results
    tgi_df = tcs.saveTgiData(parameters, tgiData, filenameInfo, tgi_df) # save results
#return tgi_df