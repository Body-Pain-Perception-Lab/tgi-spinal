from VAS_function import vasRatingScale
from parameters_spinal import getParameters
from psychopy import gui

parameters = getParameters(
    subject_n = ID[0],
    tasks = ID[1],
    qst_selection = ID[2],
    lidocaine_timepoint = ID[3],
    arm = ID[4],
    warm = ID[6],
    cold = ID[7],
    comPort = ID[8])

vasRatingScale(parameters, 'pain', win=None)