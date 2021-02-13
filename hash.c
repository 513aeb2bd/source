#ifdef DEBUGHASH

#include <stdio.h>

#endif

#include <stdint.h>

typedef uint64_t ui64;
typedef uint8_t ui8;

void hash_256 (void* msg, ui64 num_bytes, ui64* hash) {
    ui8 map[256] = { 0x81, 0x59, 0x94, 0xb1, 0x10, 0x47, 0x86, 0x70
            , 0x2c, 0xaf, 0x4f, 0x0f, 0x0e, 0x06, 0x3d, 0xc4
            , 0x37, 0xd8, 0x97, 0x1a, 0xf2, 0x4a, 0x64, 0xae
            , 0x01, 0x93, 0x9f, 0x30, 0xab, 0xb9, 0x74, 0x2d
            , 0x92, 0x6b, 0xe2, 0x2f, 0x03, 0x23, 0xdb, 0xa9
            , 0xde, 0x04, 0x42, 0xb7, 0x19, 0xc9, 0x8a, 0xc7
            , 0xe5, 0xc3, 0xf8, 0x36, 0x17, 0x08, 0xf3, 0xf5
            , 0x38, 0x9b, 0x1f, 0x46, 0xff, 0x5d, 0xbb, 0x58
            , 0xd7, 0xfd, 0x68, 0x84, 0x41, 0xea, 0x11, 0x82
            , 0xb0, 0xcd, 0xaa, 0x25, 0xe0, 0x0b, 0x14, 0x1c
            , 0xcc, 0xf4, 0xee, 0x76, 0x85, 0x3e, 0xa8, 0x40
            , 0xbc, 0x79, 0x62, 0x26, 0x5b, 0x8c, 0xc8, 0xa3
            , 0x2a, 0x5a, 0x56, 0x39, 0xd1, 0xed, 0x1d, 0xe9
            , 0xf9, 0x3f, 0xca, 0x12, 0x24, 0xb2, 0xd2, 0xf1
            , 0x3b, 0xbf, 0x2e, 0x6c, 0xcf, 0xa7, 0x69, 0x73
            , 0x90, 0x13, 0x0d, 0x99, 0x67, 0x6f, 0x8d, 0xc2
            , 0xcb, 0x53, 0x7f, 0x22, 0x6d, 0x4b, 0x66, 0x4e
            , 0x29, 0xbd, 0xfb, 0x3c, 0x31, 0xd6, 0x89, 0xe7
            , 0x20, 0x9e, 0xd4, 0x18, 0xdc, 0xe8, 0x55, 0xfc
            , 0x48, 0xc5, 0x16, 0xe6, 0x88, 0x87, 0x7b, 0xb5
            , 0xb4, 0x80, 0xa5, 0x0c, 0xf6, 0xf0, 0x7e, 0xd3
            , 0x52, 0xfa, 0x54, 0xd9, 0x02, 0x7c, 0x45, 0x50
            , 0xad, 0xa0, 0xac, 0x8b, 0x21, 0x5c, 0x0a, 0x4d
            , 0x27, 0xec, 0x83, 0xe3, 0x4c, 0x71, 0x5e, 0x6e
            , 0xc1, 0x3a, 0xce, 0x75, 0xa4, 0x05, 0x8f, 0x9c
            , 0x09, 0x32, 0x72, 0xeb, 0x15, 0xef, 0xdf, 0x77
            , 0xe4, 0x91, 0x33, 0x51, 0xba, 0x96, 0x2b, 0x35
            , 0x43, 0xa2, 0xc0, 0x1e, 0x9d, 0x60, 0xb6, 0xd0
            , 0xda, 0x61, 0x28, 0x07, 0xdd, 0x9a, 0x34, 0xbe
            , 0xc6, 0x8e, 0xb8, 0x65, 0x49, 0xb3, 0xe1, 0x95
            , 0xd5, 0x00, 0x1b, 0x7a, 0x78, 0x57, 0x5f, 0x7d
            , 0xa6, 0xfe, 0x44, 0x6a, 0x98, 0xf7, 0xa1, 0x63 };
    ui8* msgchar = (ui8*)msg;
    ui8 msg_frac[64] = { 0 };
    ui8 idxrot = 0;
    ui8 idxpnt = 0;
    ui8 rotat = 0;
    ui8 dr[8];
    ui64 A, R;
    ui64* B, * M, * Ma1, * Ma2, *Ma3;
    ui8* Apart = (ui8*)&A;

    // misc, temp vars
    ui64 i_byte, i_byte_last, t, i_rep;
    ui8 swp;

    // operation begin

    hash[0] = 0xcc545cee1e0ab8f6;
    hash[1] = 0xa732f2564dda012a;
    hash[2] = 0xe63bf7079267b48b;
    hash[3] = 0x46377d840ee0e2f8;

    // pad leading zero first fraction of message
    // if num_bytes divisible by 64, no padding
    t = num_bytes & 63;
    i_rep = 64;

    for (;;) {
        if (!t) {
            break;
        }

        t -= 1;
        i_rep -= 1;
        msg_frac[i_rep] = msgchar[t];
    }

#ifdef DEBUGHASH
    printf ("input string length:    %6u\n", num_bytes);
    printf ("0-padded string length: %6u\n", i_rep & 63);
    printf ("total string length:    %6u\n\n", num_bytes + (i_rep & 63));

    printf ("    Hash0: %016llx %016llx %016llx %016llx\n"
            , hash[3], hash[2], hash[1], hash[0]);

    i_rep = 0;
#endif

    // make code to operate at least 8 times
    // if num_bytes == 0, num_bytes = 1
    num_bytes |= !num_bytes;

    // iterate for every 8-byte (from last to first)
    i_byte = num_bytes;
    i_byte_last = 64;

    for (;;) {
        // if num_bytes divisible by 64, i_byte can be zero
        // if not, i_byte_last can be zero
        if (!(i_byte && i_byte_last)) {
            break;
        }

        // get current message
        if (i_byte <= (num_bytes & 63)) {
            i_byte_last -= 8;
            M = (ui64*)(msg_frac + i_byte_last);
            Ma1 = (ui64*)(msg_frac + (i_byte_last ^ 24));
            Ma2 = (ui64*)(msg_frac + (i_byte_last ^ 40));
            Ma3 = (ui64*)(msg_frac + (i_byte_last ^ 56));
        }
        else {
            i_byte -= 8;
            M = (ui64*)(msgchar + i_byte);
            Ma1 = (ui64*)(msgchar + (i_byte ^ 24));
            Ma2 = (ui64*)(msgchar + (i_byte ^ 40));
            Ma3 = (ui64*)(msgchar + (i_byte ^ 56));
        }

        // calculate A
        *(ui64*)dr = hash[0] + (*M ^ *Ma1 ^ ~*Ma2 ^ *Ma3);
        idxpnt += dr[3] & dr[5] ^ dr[7];
        idxpnt += dr[2] & dr[4] ^ dr[6];
        idxpnt += dr[1] & dr[7] ^ dr[5];
        idxpnt += dr[0] & dr[6] ^ dr[4];
        idxpnt += dr[7] & dr[1] ^ dr[3];
        idxpnt += dr[6] & dr[0] ^ dr[2];
        idxpnt += dr[5] & dr[3] ^ dr[1];
        idxpnt += dr[4] & dr[2] ^ dr[0];

#ifdef DEBUGHASH
        printf ("rep %u\n", i_rep);
        printf ("  M* = %016llx | M1 = %016llx | M2 = %016llx | M3 = %016llx\n"
                , *M, *Ma1, *Ma2, *Ma3);
        printf ("  hash0 add (M* xor M1 xor (not M2) xor M3) = %016llx\n"
                , *(ui64*)dr);
        printf ("  new point idx = %02x | ", idxpnt);
#endif

        Apart[0] = map[idxpnt];
        Apart[1] = map[idxpnt ^ 1];
        Apart[2] = map[idxpnt ^ 2];
        Apart[3] = map[idxpnt ^ 3];
        Apart[4] = map[idxpnt ^ 4];
        Apart[5] = map[idxpnt ^ 5];
        Apart[6] = map[idxpnt ^ 6];
        Apart[7] = map[idxpnt ^ 7];
        A += hash[1];

#ifdef DEBUGHASH
        printf ("map data = %016llx | ", A - hash[1]);
        printf ("A = %016llx\n", A);
#endif

        // calculate R
        *(ui64*)dr = hash[1] & hash[2] | ~hash[1] & hash[3];
        idxrot += dr[0] + dr[1] + dr[2] + dr[3]
                + dr[4] + dr[5] + dr[6] + dr[7] + idxpnt;
        rotat = map[idxrot] & 0x3f;

        B = (ui64*)dr;
        R = *B << rotat | *B >> (64 - rotat);

#ifdef DEBUGHASH
        printf ("  hash1 and hash2 xor (not hash1) and hash3 = %016llx\n"
                , *(ui64*)dr);
        printf ("  rotat idx = %02x | ", idxrot);
        printf ("masked rotat count = %02x | ", rotat);
        printf ("B = %016llx | B rol %02x = %016llx |\n", *B, rotat, R);
#endif

        // complete a round
        t = hash[3];
        hash[3] = hash[2];
        hash[2] = R + t;
        hash[1] = hash[0];
        hash[0] = A + R;

#ifdef DEBUGHASH
        i_rep += 1;
        printf ("    Hash%u = %016llx %016llx %016llx %016llx\n"
                , i_rep, hash[3], hash[2], hash[1], hash[0]);
#endif

        // permute map data
        t = 8;

        for (;;) {
            if (!t) {
                break;
            }

            t -= 1;
            swp = map[idxrot ^ t << 3];
            map[idxrot ^ t << 3] = map[idxpnt ^ t];
            map[idxpnt ^ t] = swp;
        }
    }
}
