#include "veyra/engine/DisplayFgBudget.h"
#include "veyra/engine/PresentationSettings.h"
#include <cassert>
#include <iostream>
int main(){using namespace veyra::engine; for(unsigned m=2;m<=6;++m)assert(displayFgMultiplierSelectable(FrameGenerationBackend::Rife,m));assert(!displayFgMultiplierSelectable(FrameGenerationBackend::Rife,7));assert(displayFgAutoMultiplier(FrameGenerationBackend::Rife,30,172,6)==6); PresentationSettings p;p.outputRate=OutputRateMode::Custom;p.customFps=172;assert(p.valid());p.customFps=1001;assert(!p.valid());PresentationCadence c;const int64_t interval=10000000/172;c.rateSubmitted(10000000,interval);for(int i=1;i<=172;++i){auto next=c.rateDue(0,interval);assert(next==10000000+i*interval);c.rateSubmitted(next,interval);}std::cout<<"PASS: 2X–6X, 7X rejection, 30fps/172 target, custom cap and cadence\n";}
