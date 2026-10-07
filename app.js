const plans=['Quick 10-15 min','Long walk, no rush','Coffee stop','Around the block'];
function minsUntil(ts){return Math.max(0, Math.ceil((ts-Date.now())/60000));}
function status(p){if(!p.startAt) return p.when?('Starts in '+p.when+' min'):'Out now'; const left=minsUntil(p.startAt); return left>0?('Starts in '+left+' min'):'Out now';}
let me={out:null};
try{me.out=JSON.parse(localStorage.getItem('along-out')||'null')}catch(e){}
function publish(wait, mode){const startAt=Date.now()+wait*60000; me.out={wait, mode, startAt, offAt:startAt+30*60000}; localStorage.setItem('along-out', JSON.stringify(me.out));}
function tick(){if(me.out && Date.now()>=me.out.offAt){me.out=null; localStorage.removeItem('along-out'); alert('Walk ended itself, 30 min after the start.');}}
setInterval(tick,15000);
window.alongTimers={status, publish, minsUntil};
