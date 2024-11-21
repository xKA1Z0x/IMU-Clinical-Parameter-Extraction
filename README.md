# IMU-Clinical-Parameter-Extraction V1.2.0

# Major update in V1.2.0:
1. Orientation Correction Function created and added to both Walk and Stairs pipelines
2. Cadence function for stairs now have ascending and descending calculations separately
3. Stairs main pipeline asks for alternating and non-alternating gait for ascending and descending parts separately.
   
#
## Objective
This pipeline helps you extracting over 100 important parameters from clinical assessments such as gait, balance and hand function. It can process IMU signals and extract gait and balance parameters. 
## Important 
1. This pipeline is currently compatible with Xsens IMU sensors and requires sensor parameters such as "Position", "Acceleration", "Orientation", "JointAngle", "Velocity", and "AngularVelocity".
2. This pipeline requires at least 8 IMU sensors placed on feet (or shanks), thighs, lumbar, trunk, and wrists. Having fewer sensors requires customization and turning off some feature extraction commands. 
3. This pipeline can explore variety of clinical assessment tests:
   Gait: Walking tests, TUG, Stair climbing, Functional Gait Assessment (FGA)
   Balance: Mini Balance Evaluation System Test (MiniBEST)
   Hand Function: Action Research Arm Test (ARAT)
   Other: Amputee Mobility Predictor (AMPPro)


## How to use:
Each clinical assessment task has its own unique folder. Each folder contains a README file for more information and tutorial. 
   
