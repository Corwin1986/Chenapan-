"""Original 32-bar chiptune, composed for Avis de turbulence; no sampled music."""
import numpy as np, wave
from pathlib import Path
rate=22050; bpm=136; step=60/bpm/2; bars=32
out=np.zeros(int(bars*8*step*rate))
rng=np.random.default_rng(93)
# Bespoke phrases, with two contrasting sections and a turnaround.
phrases=[[76,0,79,74,76,72,0,74],[79,81,0,79,76,74,72,0],
[74,77,81,0,79,77,74,72],[71,74,0,77,76,74,71,0],
[84,79,81,76,0,79,74,76],[77,0,81,79,77,74,76,0],
[76,79,84,83,81,0,79,77],[74,71,72,0,67,71,74,0]]
roots=[48,45,50,43,48,53,45,43]
def note(m,start,duration,gain,kind='pulse'):
 if not m:return
 n=int(duration*rate); t=np.arange(n)/rate; f=440*2**((m-69)/12)
 if kind=='pulse': y=np.where((t*f)%1<.25,1.,-1.)
 else:y=2/np.pi*np.arcsin(np.sin(2*np.pi*f*t))
 env=np.minimum(t/.007,1)*np.minimum((duration-t)/.025,1)*np.exp(-t*2)
 i=int(start*rate); n=min(n,len(out)-i)
 out[i:i+n]+=gain*y[:n]*env[:n]
for bar in range(bars):
 phrase=phrases[(bar%8 if bar<16 else (bar%8+4)%8)]
 root=roots[bar%8]
 for j,m in enumerate(phrase):note(m, (bar*8+j)*step,step*.8,.14)
 for j in range(0,8,2):note(root+(12 if j==6 else 0),(bar*8+j)*step,step*1.6,.20,'triangle')
 for j in [1,3,5,7]:note(root+24+([0,7,12,7][j//2]),(bar*8+j)*step,step*.65,.055)
 for j in range(8):
  n=int(rate*.055);t=np.arange(n)/rate;i=int((bar*8+j)*step*rate)
  noise=rng.uniform(-1,1,n)*np.exp(-t*75)*(.045 if j%2 else .025)
  out[i:i+n]+=noise
out=np.tanh(out*1.4)*.8
path=Path(__file__).resolve().parents[1]/'assets/village_chiptune.wav'
with wave.open(str(path),'wb') as w:w.setparams((1,2,rate,0,'NONE','not compressed'));w.writeframes((out*32767).astype('<i2').tobytes())
print(path,round(len(out)/rate,2),'seconds')
