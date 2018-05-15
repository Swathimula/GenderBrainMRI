#   This will convert the brain MRI MetaImages to data structures (MAT files)
#   Author: Swathi M. Mula
#   Date Created:   April 26, 2018
#   Last Modififed: May 14, 2018
import SimpleITK as sitk
import numpy as np
import scipy.io as sio

#   folder to import the MetaImages
importdata_folder  =  '/Users/swathi/Documents/Projects/Mula_MIDAS_2018/Raw Data/'

#   folder to export the MAT files
exportdata_folder = '/Users/swathi/Documents/Projects/Mula_MIDAS_2018/Training/MFiles/'


for subject in range(110):

    # This loads the T1 weighted MRI and converts to MAT files
    try:
        imageT2 = sitk.ReadImage(importdata_folder + 'Normal'+ '{:03}'.format(subject) + '-T2.mha')
        max_index = imageT2.GetDepth()
        imageT2_list = [sitk.GetArrayFromImage(imageT2[:,:,i]) for i in range(max_index)]
        imageT2_array = np.asarray(imageT2_list)

        # Saving the converted T1 weighted data to the export folder
        sio.savemat(exportdata_folder +'T2array'+ '{:03}'.format(subject) +'.mat', mdict = {'T2array' : imageT2_array})

    except Exception:
        print('The subject'+ str(subject) + 'does not have T2.mha')

    # This loads the T2 weighted MRI and converts to MAT files
    try:
        imageT1 = sitk.ReadImage(importdata_folder + 'Normal'+ '{:03}'.format(subject) + '-T1-Flash.mha')
        max_index = imageT1.GetDepth()
        imageT1_list = [sitk.GetArrayFromImage(imageT1[:,:,i]) for i in range(max_index)]
        imageT1_array = np.asarray(imageT1_list)

        # Saving the converted T2 weighted data to the export folder
        sio.savemat(exportdata_folder +'T1array'+ '{:03}'.format(subject) +'.mat', mdict = {'T1array' : imageT1_array})

    except Exception:
        print('The subject'+ str(subject) + 'does not have T1-Flash.mha')
