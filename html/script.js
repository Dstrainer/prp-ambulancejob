window.addEventListener('message',e=>{if(e.data.action==='open'){
document.getElementById('patient-name').innerText=e.data.target;
document.getElementById('medical-ui').classList.remove('hidden');
['head','torso','leftArm','rightArm','leftLeg','rightLeg'].forEach(part=>fetch(`https://${GetParentResourceName()}/getInjuries`,{
method:'POST',body:JSON.stringify({part,target:e.data.target})}).then(r=>r.json()).then(d=>{
const hs=document.querySelector(`.hotspot.${part}`);
d.injuries.length?hs.classList.add('injured'):hs.classList.remove('injured');
}));}});

document.querySelectorAll('.hotspot').forEach(hs=>hs.addEventListener('click',()=>{
const part=hs.dataset.part;
document.getElementById('part-name').innerText=part;
fetch(`https://${GetParentResourceName()}/getInjuries`,{
method:'POST',body:JSON.stringify({part,target:document.getElementById('patient-name').innerText})})
.then(r=>r.json()).then(d=>{
const list=document.getElementById('injuries-list');
list.innerHTML=d.injuries.length?d.injuries.map(i=>`<li>${i}</li>`).join(''):'<li>No wounds</li>';
['head','torso','leftArm','rightArm','leftLeg','rightLeg'].forEach(p=>fetch(`https://${GetParentResourceName()}/getInjuries`,{
method:'POST',body:JSON.stringify({part:p,target:document.getElementById('patient-name').innerText})})
.then(r=>r.json()).then(dd=>{const h=document.querySelector(`.hotspot.${p}`);
dd.injuries.length?h.classList.add('injured'):h.classList.remove('injured');}));
});
}));

['consciousness','pulse','temperature'].forEach(act=>document.getElementById(`check-${act}`)
.addEventListener('click',()=>fetch(`https://${GetParentResourceName()}/quickAction`,{method:'POST',body:JSON.stringify({action:act})})));

document.getElementById('close-ui').addEventListener('click',()=>{
document.getElementById('medical-ui').classList.add('hidden');
fetch(`https://${GetParentResourceName()}/close`);SetNuiFocus(false,false);
});