# Roadmap and Milestones

This file contains the general road map for develop and the current Milestones that have been achieved

## MVP 0.1:  released May 31, 2023  (tag: MVP_0.1)
   - initial implementation with frame work to support subsequent MVPs
   - encoding of all Arithmetic, Logic, and Shift instructions supported
   - execution of all native  Arithmetic, Logic, and Shift instructions supported

---

## MVP 0.2:
   - full implementation of labels
     - creation of the .labels file
     - loading or preprocessing of the .labels file

   - limited processing of the data segment to support the following directives:
     .byte, .half, .byte, and .align

   - encoding of Load and Store instructions with alternative syntax
   - execution of Load and Store instructions with alternative syntax
        - review the output of the MEM depiction
   - encode of Branch and Jump instructions, with labels predefined <br> 
     labels that appear in the future are marked as deferred within the encodings

## MVP 0.3:
  - execution loop 
  - execution of Branch and Jump instructions
  - dumping of the .text file

## MVP 0.4:
  - refinement of pseudo instructions
  - dumping of the .core file


====== Here




## MVP 0.5:
   - Commands: first draft of list to be supported, partial implementation
   - first cut of command line arguments

   - implementation of Syscalls and Traps
   - triggering of traps, e.g., on addition overflow


## MVP 0.X:
   - Complete list of mips_cli commands
   - document writeup