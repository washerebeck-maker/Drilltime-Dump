
const phone = document.getElementById('nokia-phone');
const screen = document.getElementById('phone-screen');

// Listen for NUI messages
window.addEventListener('message', (event) => {
	const data = event.data;

	if (data.action === 'open') {
		screen.innerHTML = ''; // clear screen
		phone.classList.add('visible');

		// Loop through the config keys
		Object.entries(data.items).forEach(([key, item]) => {
			const btn = document.createElement('button');
			btn.className = 'menu-btn';
			btn.textContent = item.Label; // show label
			btn.onclick = () => {
				fetch(`https://${GetParentResourceName()}/onSelect`, {
					method: 'POST',
					headers: { 'Content-Type': 'application/json' },
					body: JSON.stringify({ selected: key }) // use key (e.g. "npc")
				});
				phone.classList.remove('visible');
			};
			screen.appendChild(btn);
		});
	} 
	
	else if (data.action === 'close') {
		phone.classList.remove('visible');
	}
});

// ESCAPE KEY

document.addEventListener('keydown', (event) => {
  if (event.key === 'Escape') {
    phone.classList.remove('visible');
    fetch(`https://${GetParentResourceName()}/onClose`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' }
    });
  }
});

