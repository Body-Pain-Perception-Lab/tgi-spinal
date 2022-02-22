# Authors: Francesca Fardo <francesca@cfin.au.dk>, Thea Rolskov Sloth, Signe Kirk Brødbæk
#import os
from parameters_lidocaine import getParameters
from task_functions import run
from psychopy import gui

#Create popup information box
popup = gui.Dlg(title = "Participant Information")
popup.addField("Subject number",'TLH15') # Example
popup.addField("Task", choices=["Demo_QST","QST","Demo_TGI","TGI","Demo_TSL2","TSL2"]) # Dropdown menu
popup.addField("Start QST from", choices = ["CDT","WDT","TSL1","CPT","HPT"])
popup.addField("lidocaine_timepoint", choices=["00","45","90"]) # Dropdown menu
popup.addField("arm", choices=["A","B"]) # Dropdown menu
popup.addFixedField(" ", "--- For TGI only ---")
popup.addField("TGI Warm","39.99") # Example
popup.addField("TGI Cold","28.92") # Example
popup.addField("comPort", choices=["/dev/tty.usbmodem14101","COM3"])#"COM3") # Example
popup.show()
if popup.OK: # To retrieve data from popup window
    ID = popup.data 
elif popup.Cancel: # To cancel the experiment if popup is closed
    core.quit()

#extract parameters from gui
parameters = getParameters(
    subject_n = ID[0],
    tasks = ID[1],
    qst_selection = ID[2],
    lidocaine_timepoint = ID[3],
    arm = ID[4],
    warm = ID[6],
    cold = ID[7],
    comPort = ID[8])

#run experiment
run(parameters)