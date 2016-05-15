using UnityEngine;
using System.Collections;

public class LayerController : MonoBehaviour {

	int topLayer = 15;
	int bottomLayer = 10;
	int currentLayer = 15;

	// Update is called once per frame
	void Update () {
		if (Input.GetKeyDown(KeyCode.Z) && currentLayer > bottomLayer) {
			hideDimension(currentLayer--);
		}
		if (Input.GetKeyDown(KeyCode.X) && currentLayer < topLayer) {
			showDimension(++currentLayer);
		}
	}

	void hideDimension(int layerToHide) {
		Camera.main.cullingMask &= ~(1 << layerToHide);

	}
	
	void showDimension(int layerToShow) {
		Camera.main.cullingMask |= (1 << layerToShow);
	}
}
