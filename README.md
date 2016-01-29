## S²E²C Algorithm
### *Self-stabilizing End-to-End Communication in (Bounded Capacity, Omitting, Duplicating and non-FIFO) Dynamic Networks*
### *A Practical Approach in TinyOS*

This is the main repository for my thesis work, done at Chalmers University of Technology in Göteborg, Sweden.
It represents the final stage of my Master of Engineering degree in Computer Science.
My assignment was to implement the algorithm developed by my supervisor, Elad Michael Schiller, in TinyOS and test in different circumstances to determine its practical functionality, advantages, and limitations.

The original paper can be found on the [Gulliver Publications page](http://www.chalmers.se/hosted/gulliver-en/documents/publications "Gulliver Publications").

The direct link to the full text is available online through [Springer Link](http://link.springer.com/chapter/10.1007%2F978-3-642-33536-5_14).

----------------------------------------------------------------------

### Structure

There are three main folders in which a version of the algorithm can be found.
Each new version builds upon the previous one and adds functionality, as explained below.
This makes it easy to quickly set up simulations and experiments for each version, and allows to quickly compare code of each version if needed.

The four versions are:

1. First-Attempt
2. Full algorithm: Final_single_hop
3. Full algorithm with multi-hopping

All versions work through point-to-point communication. This means a Sender sends his messages to one specific Receiver, and the Receiver acknowledges the messages back to the original Sender.

#### First-Attempt

This is the first attempt version of the algorithm as described in the original paper.
The Sender sends each message with an Alternating Index value and a unique Label for each message. The Receiver acknowledges each message upon arrival and the Sender will only send the next message if the current one has been properly acknowledged.
Once the Receiver receives a certain amount of messages, the algorithm delivers these messages to the Application Layer.
The variable CAPACITY determines this amount of messages in the network, the value of which can be adjusted according to the needs of the implementation in the algorithm itself.

#### Full algorithm: Final_single_hop

These are the full Sender and Receiver algorithms as described in the paper. On top of the basic first attempt functionality the algorithm divides the messages in packets and sends them to the Receiver. This is the First Attempt algorithm, together with the Packet Generation functionality, and the Error Correcting Codes.

#### Full algorithm with multi-hopping

In a real-life situation, it is very likely that the Sender and Receiver nodes are not within radio distance of each other. To fully observe the performance of the algorithm in such a real-life environment, it is therefore necessary to add the functionality of Multi-Hop routing through an appropriate Multi-Hop algorithm. In this case we have chosen for the IPv6 Routing Protocol for Low Power and Lossy Networks (RPL, pronounced 'Ripple'). As you will be able to see in the code, this brings along significant changes to the Sending and Receiving algorithm. The reason is that this protocol uses UDP functionality to send and receives messages. To do this it uses custom TinyOS UDP functions as defined in BLIP 2.0 (Berkely Low-Power IP Stack).

----------------------------------------------------------------------

### Usage  

We work with a separate Sender and Receiver algorithm. The code is therefore implemented in each version in two folders; *Send* and *Receive*. Each of these folder contains four files. I've made the naming conventions consistent for each file. I will show the structure for the *Send* algorithm, but it is identical to the *Receiver* algorithm except for the file names.

#### Makefile

You can customize all the Makefile options if you need something changed. I'll explain the two most useful ones here, for the rest I refer to the TinyOS documentation and specifically BLIP 2.0. Both of these options are only available in the Multi-Hop version.

`CFLAGS += -DRPL_ROOT_ADDR=1`

This changes the address of the root node in the RPL network. The number represents the node id. You can change this to any arbitrary node id in the network.

`PFLAGS += -DIN6_PREFIX=\"fec0::\"`

With this you can set the IPv6 prefix used to address the nodes in the network.

I've implemented the Printf functionality in all the versions of the algorithm. To use it, simply use the standard `printf()` C-function followed by the `printfflush()` function to write the information to the node output.

#### SECSend.h

There are two AM_TYPE numbers declared for the messages sent between Sender and Receiver. This way you can multiplex the radio channel. Again you can change this to any arbitrary number.

```
AM_SECMSG = 5
AM_ACKMSG = 10
```

Two different messages travel across the network:

* SECMsg: the data messages from the Sender to the Receiver
* ACKMsg: the acknowledgement messages from the Receiver to the Sender

```
typedef nx_struct SECMsg {
  nx_uint16_t ai;
  nx_uint16_t lbl;
  nx_uint16_t dat;
  nx_uint16_t nodeid;
} SECMsg;
```

SECMsg defines four fields:

* ai: the current Alternating Index
* lbl: the label of the message, which is unique for each message in relation to the current Alternating Index
* dat: the data it contains. In my algorithm this is simply an incrementing counter value.
* nodeid: the nodeid of the Sender

```
typedef nx_struct ACKMsg {
	nx_uint16_t ldai;
	nx_uint16_t lbl;
	nx_uint16_t nodeid;
} ACKMsg;
```

ACKMsg defines three fields:

* ldai: the Last Delivered Alternating Index value
* lbl: the label of the message, which is the label of the incoming message for which the Receiver acknowledges the arrival.
* nodeid: the nodeid of the Receiver

#### SECSendC.nc

This is the **Configuration** file for the TinyOS application. Unless you want to add new functionality to the algorithm, you should not change anything in here.

#### SECSendP.nc

The **Component** file includes the actual operational logic of the algorithm.
Here you can adjust three elements.

The *capacity* of the network, as described in the original paper, is determined using this variable. This comes down to how many messages the Receiver will collect before delivering them to the Application Layer.

`#define capaccity (pl-1)`

In the packet generation function, there are two predefined values. This function looks at the array of messages, which are fetched from the Application Layer at the Sender side, as a matrix. It then transposes this matrix to generate the packets that will be send over the network.

`#define SENDNODES 3`

I've created this variable to make the algorithm easily scale according to the amount of nodes being used in the network. Since each Sender sends to one specific Receiver and vice-versa, the amount of Sender-nodes in the network (which should be equal to the amount of Receiver nodes) determines the address node id of the Receiver and Sender mote in each respective algorithm.
