#include "..\terasic_lib\terasic_includes.h"
class FatSfn_t {
 public:
  /** Flags for base and extension character case and LFN. */
  alt_u8 flags;
  /** Short File Name */
  alt_u8 sfn[11];
};
