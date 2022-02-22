# Authors: Francesca Fardo <francesca@cfin.au.dk>, Thea Rolskov Sloth, Signe Kirk Brødbæk
import os
import pandas as pd
import numpy as np
from psychopy import data, visual, core, event
import platform

def getParameters(subject_n):
    """Create parameters for all tasks
    Many parameters, aesthetics, and options are controlled by the 
    parameters/dictonary defined here. 
    These are intended to provide 
    flexibility and modularity to the tasks. In many cases, unique versions of the 
    task (e.g., different number of trials) can be created simply by changing these 
    parameters, with no further interaction with the underlying task code.
    """
    ###################
    # Define parameters
    ###################
    parameters = {} # initialize parameters
    # Variable parameters
    parameters['subject_n'] = subject_n
    parameters['tasks'] = tasks
    parameters['qst_selection'] = qst_selection
    parameters['lidocaine_timepoint'] = lidocaine_timepoint
    parameters['arm'] = arm
    parameters['TGIwarm'] = warm
    parameters['TGIcold'] = cold
    parameters['comPort'] = comPort
    
    # Fixed Parameters
    if platform.system() == 'Darwin': 
        parameters['slash'] = '/' # mac paths
    elif platform.system() == 'Windows': 
        parameters['slash'] = '﻿\\' # win paths
    parameters['allowedKeys'] = ['left', 'right',' up', 'down','q', 'space', 'p'] #redundant?
    parameters['nextTask'] = ['space']
    parameters['quit'] = ['q']
    parameters['path'] = os.getcwd()
    parameters['pathResults'] = parameters['path'] +  parameters['slash'] + 'results' +  parameters['slash'] + subject_n
    #Saving data
    # preparing df
    parameters['trialInfo'] = tasks + '_' + lidocaine_timepoint + '_' + subject_n + '_' + arm + '_'
    parameters['columnsVas'] = ['subject_n','arm','temps','trial_n','vas','rating','time'] 
    parameters['lidocaine_df'] = pd.DataFrame(columns = parameters['columnsVas'])
    
    parameters['sumDfInfo'] = [subject_n, lidocaine_timepoint, arm]
    parameters['columnsSum'] = ['subject_n','timepoint','arm','task','threshold']
    parameters['qst_filename'] = parameters['pathResults'] + parameters['slash'] + 'QST_summary' + '.csv'
    if not os.path.isfile(parameters['qst_filename']):
        parameters['qst_df'] = pd.DataFrame(columns = parameters['columnsSum'])
    else:
        parameters['qst_df'] = pd.read_csv(parameters['qst_filename'])
    
    # Sequences
    parameters['runDemoQST']  = False
    parameters['runQST'] = False
    parameters['runDemoTSL2']  = False
    parameters['runTSL2']  = False
    parameters['runDemoTGI']  = False
    parameters['runTGI']  = False
    if parameters['tasks'] is 'Demo_QST':
        parameters['runDemoQST'] = True
    elif parameters['tasks'] is 'QST':
        parameters['runQST'] = True
    elif parameters['tasks'] is 'Demo_TSL2':
        parameters['runDemoTSL2'] = True
    elif parameters['tasks'] is 'TSL2':
        parameters['runTSL2'] = True
    elif parameters['tasks'] is 'Demo_TGI':
        parameters['runDemoTGI'] = True
    elif parameters['tasks'] is 'TGI':
        parameters['runTGI'] = True
    
    # QST
    parameters['qst_sequence'] = np.array(['CDT', 'WDT', 'TSL1', 'CPT', 'HPT'])
    if parameters['qst_selection'] is not 'CDT':
        qst_index = np.where(parameters['qst_sequence'] == parameters['qst_selection'])
        parameters['qst_sequence'] = parameters['qst_sequence'][qst_index[0][0]:len(parameters['qst_sequence'])]
    
    # define QST parameters: first value = targetT, second value = iti
    #parameters['qst_parameters'] = {'CDT': [0, 5], 'WDT': [50, 5], 'TSL1': [0, 0], 'CPT': [0, 10], 'HPT': [50, 10]}
    parameters['CDT'] =  {'base': 32, 'targetT': [0]*5, 'iti': [5]*5}
    parameters['WDT'] =  {'base': 32, 'targetT': [50]*5, 'iti': [5]*5}
    parameters['TSL1'] = {'base': 32, 'targetT': [0]*5, 'iti': [0]*5}
    parameters['CPT'] =  {'base': 32, 'targetT': [0]*5, 'iti': [10]*5}
    parameters['HPT'] =  {'base': 32, 'targetT': [50]*5, 'iti': [10]*5}
    
    # define TGI temperatures
    w, c, b = float(parameters['TGIwarm']), float(parameters['TGIcold']), 32
    parameters['tgi_stimuli'] = {'TGI': [w, c, w, c, w],
            'nonTGIcold': ([c, c, b, b, b], [b, c, c, b, b], [b, b, c, c, b], [b, b, b, c, c]),
            'nonTGIwarm': ([w, w, w, b, b], [b, w, w, w, b], [b, b, w, w, w]),
            'all_warm': [w]*5,
            'all_cold': [w]*5}
            
    # define tsl temperatures
    tsl_baseline = [b,50,b,0]
    tsl_warming = [w,50,w,0]
    tsl_cooling = [c,50,c,0]
    
    # define TSL sequences
    if (int(parameters['subject_n'][-1]) % 2) == 0: #if odd number
        parameters['tsl_sequence'] = [tsl_baseline, tsl_warming, tsl_cooling]
    if (int(parameters['subject_n'][-1]) % 2) == 1: #if even number
        parameters['tsl_sequence']  = [tsl_baseline, tsl_cooling, tsl_warming]
        
    # Texts
    parameters['texts'] = {
            'textTaskStart': "Testen begynder snart. Gør dig klar.", #redundant?
            'textEnd': "Testen er nu slut.", 
            'textNext': "Den næste test begynder snart", 
            'textNextTGI': "\n \n  Læg testapparatet på armen. Løft det af armen efter bippet.", 
            'textContinue': "Tryk på space for at fortsætte til næste test", 
            'textInstruction': {'QST_demo': "QST Demo \n \n Om lidt kommer en række forskellige tests. \n \n Vi starter om et øjeblik.",
                                'CDT_demo': "CDT Demo \n \n  Først vil vi teste din evne til at føle kulde. Vær venlig at bruge afbryderen, så snart du allerførste gang føler temperaturen skifte til kold eller koldere. Herefter vil termoden varmes op igen, indtil den når udgangstemperaturen. \n \n Denne test vil starte om få sekunder. \n \n Dette måles 1 gang.",
                                'WDT_demo': "WDT Demo \n \n Vi vil nu teste din evne til at føle varme. Vær venlig at bruge afbryderen, så snart du allerførste gang føler temperaturen skifte til varm eller varmere. Herefter vil termoden falde i temperatur igen, indtil den når udgangs-temperaturen. \n \n Denne test vil starte om få sekunder. \n \n Dette måles 1 gang.",
                                'TSL1_demo': "TSL Demo \n \n Vi vil nu teste din evne til at skelne flere på hinanden følgende temperaturskift. Brug afbryderen, så snart du føler, at temperaturen skifter til kulde eller varme.  og fortæl os samtidig, om du føler temperaturskiftet som koldt eller varmt. Det kan forekomme, at nogle af temperaturskiftene føles som ”brændende” eller ” smertefuldt varmt”. \n \n Dette måles i alt 4 gange.",
                                'CPT_demo': "CPT Demo \n \n Vi vil nu teste, hvornår du føler kulden som smertefuld mod din hud. Termoden vil langsomt køle din hud. Kulden vil på et tidspunkt skifte fra blot at føles kold til yderligere at føles som ”brændende”, ”sviende”, ”borende” eller ”smertende”.  Så snart du mærker et sådant skift, skal du bruge din afbryder. Du skal ikke vente med at bruge din afbryder, til smerten bliver uudholdelig. Herefter vil termoden varmes op igen, indtil den når udgangstemperaturen. \n \n Dette måles 1 gang. \n \n Testen vil starte om lidt. ", 
                                'HPT_demo': "HPT Demo \n \n Nu vil vi ligeledes teste, hvornår du føler varmen som smertefuld mod din hud. Termoden vil langsomt varme din hud. Varmen vil på et tidspunkt skifte fra blot at føles varm til også at føles som ”brændende”, ”sviende”, ”borende” eller ”smertende”. Så snart du mærker et sådant skift, skal du bruge din afbryder. Du skal ikke vente med at bruge din afbryder, til smerten bliver uudholdelig. Herefter vil termoden køle ned igen, indtil den når udgangstemperaturen. \n \n Dette måles 1 gang. \n \n Testen vil starte om lidt.",
                                'TSL2_demo': "TSL2 Demo \n \n Vi vil nu teste din evne til at skelne flere på hinanden følgende temperaturskift. Vent til du hører et bip. Efter bippet, brug da afbryderen så snart du mærker en ændring af temperaturen. Vær venlig at forklare om følelsen er kold eller varm, og også om det føles smertefuldt. \n \n Dette gentages 2 gange. ",
                                'TGI_demo': "TGI Demo \n \n Ved dennne test varmes eller køles din hud. Fjern testapparatet, når du hører et bip - vælg derefter hvordan du oplevede stimulus ud fra mulighederne på skærmen. \n \n Dette måles i alt 3 gange.",
                                'QST': "QST \n \n Om lidt kommer en række forskellige test. \n \n Vi starter om et øjeblik.",
                                'CDT': "CDT \n \n Ligesom vi har øvet tidligere, vil du først opleve en kølende fornemmelse på din hud. Du bedes bruge afbryderen, så snart du føler den allerførste ændring af temperaturen som ”kold” eller ”koldere”.  \n \n Dette måles i alt 3 gange.",
                                'WDT': "WDT \n \n Du bedes bruge afbryderen, så snart du føler den allerførste ændring af temperaturen som ”varm”.  \n \n Dette måles i alt 3 gange.",
                                'TSL1': "TSL \n \n Du bedes bruge afbryderen, så snart du føler en ændring af temperaturen på din hud. Vær venlig at forklare om følelsen er kold, varm og også om det føles smertefuldt. \n \n Dette måles i alt 6 gange.",
                                'CPT': "CPT \n \n Du bedes bruge afbryderen, så snart ”kulde” fornemmelsen skifter til yderligere at føles ”brændende”, ”sviende”, ”borende” eller ”smertende”. \n \n Dette måles i alt 3 gange.", 
                                'HPT': "HPT \n \n Du bedes bruge afbryderen, så snart ”varme” fornemmelsen skifter til yderligere at føles ”brændende”, ”sviende”, ”borende” eller ”smertende”. \n \n Dette måles i alt 3 gange.",
                                'TSL2': "TSL2 \n \n Vent til du hører et bip. Efter bippet, brug da afbryderen så snart du mærker en ændring af temperaturen. Vær venlig at forklare om følelsen er kold eller varm, og også om det føles smertefuldt. \n \n Dette gentages 6 gange.",
                                'TGI': "TGI \n \n Ved dennne test varmes eller køles din hud. Fjern testapparatet, når du hører et bip - vælg derefter hvordan du oplevede stimulus ud fra mulighederne på skærmen. \n \n Dette måles i alt 9 gange. "},
            '+' : "+",
            'textBp' : "Der blev trykket på knappen",
            'textVasTitle': {'pain': "Hvor smertefuldt var stimulus, lige da du hørte bippet?",
                            'unpleasantness': "Hvor ubehageligt var stimulus, lige da du hørte bippet?",
                           'cold': "Hvor koldt føltes stimulus, lige da du hørte bippet?",
                           'warm': "Hvor varmt føltes stimulus, lige da du hørte bippet?"},
            'textVasAnchors': {'pain': ["Ingen smerte", "Værst tænkelige smerte"],
                           'unpleasantness': ["Intet ubehag", "Værst tænkelige ubehag"], #no unpleasantness; worst unpleasantness imaginable
                           'cold': ["Overhovedet ikke kold","Ekstremt koldt"], #no cold; extremely cold
                           'warm': ["Overhovedet ikke varm","Ekstremt varmt"]}} #no warm; 100 extremely warm
    parameters['textSize'] = 0.07

    # VAS
    parameters['vasParameters'] = {
        'low': 0,
        'high': 100, 
        'marker': 'triangle', 
        'markerColor': 'gold',
        'tickMarks': [0,100], 
        'stretch': 1.5, 
        'noMouse': False, 
        'tickHeight': 1.5,
        'textColor': 'White',
        'pos': [0,0],
        'height': 0.05,
        'textColor': 'White',
        'increment': 0.3,
        'textSize': 0.7,
        'showAccept': True,
        'acceptSize': 3,
        'acceptPreText': 'Tryk på linjen for at vælge en værdi',
        'showValue': False,
        'acceptText': 'Tryk her, når du har valgt en værdi'
        }

    # Win
    ''' win0 = experimenter' screen/monitor. 
        win1 = participant's screen/monitor
    '''
    #parameters['screensize'] = (1920,1080)
    parameters['win0'] = visual.Window(screen=0,
                                      fullscr=True)
    parameters['win1'] = visual.Window(screen=1,
                                      fullscr=True)

    # Descriptors
    parameters['descriptors'] = {
            'pos': {
                'intro': (0,0.7),
                'outro': (0,-0.7) 
                },
            'text': {
                'burn': "Brændende",
                'warm': "Varm",
                'neutral': "Neutral",
                'cold': "Kold",
                'freez': "Isnende",
                'other': "Andet",
                'intro': "Hvordan føltes stimulus, lige da du hørte bippet? \n Du må gerne vælge flere ord.",
                'outro': "Tryk her, når du er færdig med at vælge ord"
                },
            'rectHeight': 0.2,
            'rectWidth': 1
            }

    # Create Results directory if it does not exist already
    if not os.path.exists(parameters['pathResults']):
        os.makedirs(parameters['pathResults'])

    return parameters