# CbLocomotion

Controls the stepper motors for locomotion and steering. The interface is through [CbLocomotion.Locomotion](lib/cb_locomotion/locomotion.ex). The left and right steppers are also named `GenServer`s and send a signal to move the wheels roughly every millisecond, at maximum rate.

Note that neither Erlang or Linux are ideal for this kind of controller, being preemptively multitasking systems. It is the difference between [Hard and Soft Realtime](https://en.wikipedia.org/wiki/Real-time_computing#Criteria_for_real-time_computing). The ideal setup would be to use a microcontroller, such as an [Arduino clone](https://leanpub.com/makingtheshrimp/read), to control the motors in Hard Realtime, and control via the Pi pins (either GPIO or UART). That would complicate assembly and coding however.

As it turns out, the approach implemented here works well enough. There's not a lot of performance to gain on the cheap 28Byj stepper motors.
