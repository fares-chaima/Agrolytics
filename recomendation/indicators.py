import numpy as np
import rasterio

def read_band(path):
    with rasterio.open(path) as band:
        return band.read(1).astype(float)

def compute_ndvi(nir, red):
    return (nir - red) / (nir + red + 1e-6)

def compute_ndwi(green, nir):
    return (green - nir) / (green + nir + 1e-6)

def compute_savi(nir, red, L=0.5):
    return ((nir - red) / (nir + red + L)) * (1 + L)

def compute_evi(nir, red, blue):
    return 2.5 * ((nir - red) / (nir + 6 * red - 7.5 * blue + 1))

def compute_bsi(red, swir, nir, blue):
    num = (red + swir) - (nir + blue)
    den = (red + swir) + (nir + blue) + 1e-6
    return num / den

def compute_lst(tirs_band):
    return tirs_band * 0.02 - 273.15  # approximation for Landsat

def compute_all_indicators(bands):
    red = read_band(bands["red"])     # B4
    nir = read_band(bands["nir"])     # B8
    green = read_band(bands["green"]) # B3
    blue = read_band(bands["blue"])   # B2
    swir = read_band(bands["swir"])   # B11
    tirs = read_band(bands["tirs"])   # LST - thermal band (Landsat)

    return {
        "NDVI": float(np.nanmean(compute_ndvi(nir, red))),
        "NDWI": float(np.nanmean(compute_ndwi(green, nir))),
        "SAVI": float(np.nanmean(compute_savi(nir, red))),
        "EVI": float(np.nanmean(compute_evi(nir, red, blue))),
        "BSI": float(np.nanmean(compute_bsi(red, swir, nir, blue))),
        "LST": float(np.nanmean(compute_lst(tirs)))
    }
