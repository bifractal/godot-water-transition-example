# Water Transition Example - Plugin Branch

This example project demonstrates the water transition shader from my "Drone Simulator" prototype project made in Godot Engine 3.5+.

All required code is rewritten in GDScript for this project (instead of C++). A simple first person character is provided to walk around and dive into the water.

![Water Transition Shader - Preview Screenshot](images/preview.png)

## Plugin Setup
* Add node **WaterTransitionShader** to your player character or to the main scene node via **Add Child Node**.
* Disable **Cull Mask** layer **16** on the main camera or the player's camera, depending on your setup.
* Call **update_main_camera()** inside your **_process()** function and pass the main camera object to it.
* Optionally, adjust the script variables for the water level, colors etc.

If the post processing effect is on top of your control nodes, try to move the water transition shader node up or down inside your scene node hierarchy.
