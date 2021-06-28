#include "hbsocket.ch"
PROCEDURE Main()
   LOCAL aIFace
   FOR EACH aIFace IN hb_socketGetIFaces( , .t. )
    // ? "Family:", aIFace[ HB_SOCKET_IFINFO_FAMILY ]
    ? "Name:", aIFace[ HB_SOCKET_IFINFO_NAME ]
    // ? "Net mask:", aIFace[ HB_SOCKET_IFINFO_NETMASK ]
    // ? "Broadcast:", aIFace[ HB_SOCKET_IFINFO_BROADCAST ]
    ? "IP:", aIFace[ HB_SOCKET_IFINFO_ADDR ], ;
        "   MAC:", aIFace[ HB_SOCKET_IFINFO_HWADDR ]
    ? "++++++++++++"
   NEXT
   WAIT
RETURN