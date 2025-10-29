# California county heatmap (% citing proximity) with UC & CSU overlays
# No pyproj usage; avoids set_crs/to_crs entirely.

import geopandas as gpd
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from matplotlib import patheffects as pe
from matplotlib.lines import Line2D


# --- Read counties + join data ---
gdf = gpd.read_file("dta/ca_counties/CA_Counties.shp")
gdf["fips"] = gdf["GEOID"].astype(str).str.zfill(5)

df = pd.read_csv("out/proximity_by_county.csv")
df["fips"] = df["geoid"].astype(str).str.zfill(5)

g = gdf.merge(df, on="fips", how="left")


# Bounds tell us if the shapefile is projected (meters) or degrees
xmin, ymin, xmax, ymax = g.total_bounds
is_projected_like_3857 = (abs(xmin) > 1e6 and abs(ymin) > 1e6)

print("County bounds:", g.total_bounds,
      "| projected≈3857?", is_projected_like_3857)

# ---- UC + CSU campus coordinates (lat, lon; WGS84) ----
rows = [
    # UC (10)
    ("UC Berkeley", "UC", 37.8719, -122.2585, "UCB"),
    ("UC Davis", "UC", 38.5382, -121.7617, "UCD"),
    ("UC Irvine", "UC", 33.6405, -117.8443, "UCI"),
    ("UC Los Angeles", "UC", 34.0689, -118.4452, "UCLA"),
    ("UC Merced", "UC", 37.3649, -120.4240, "UCM"),
    ("UC Riverside", "UC", 33.9737, -117.3281, "UCR"),
    ("UC San Diego", "UC", 32.8801, -117.2340, "UCSD"),
    # ("UC San Francisco","UC",37.7631,-122.4586,"UCSF"),
    ("UC Santa Barbara", "UC", 34.4139, -119.8489, "UCSB"),
    ("UC Santa Cruz", "UC", 36.9916, -122.0583, "UCSC"),
    # CSU (23)
    ("CSU Bakersfield", "CSU", 35.3503, -119.1045, "CSUB"),
    ("CSU Channel Islands", "CSU", 34.1623, -119.0430, "CSUCI"),
    ("CSU Chico", "CSU", 39.7285, -121.8460, "Chico"),
    ("CSU Dominguez Hills", "CSU", 33.8644, -118.2551, "CSUDH"),
    ("CSU East Bay (Hayward)", "CSU", 37.6547, -122.0578, "CSUEB"),
    ("Fresno State", "CSU", 36.8123, -119.7485, "Fresno"),
    ("CSU Fullerton", "CSU", 33.8826, -117.8856, "CSUF"),
    ("Cal Poly Humboldt", "CSU", 40.8734, -124.0770, "Humboldt"),
    ("CSU Long Beach", "CSU", 33.7838, -118.1141, "CSULB"),
    ("CSU Los Angeles", "CSU", 34.0669, -118.1689, "CSULA"),
    ("CSU Maritime (Vallejo)", "CSU", 38.0680, -122.2566, "Maritime"),
    ("CSU Monterey Bay", "CSU", 36.6500, -121.8000, "CSUMB"),
    ("CSU Northridge", "CSU", 34.2396, -118.5286, "CSUN"),
    ("Cal Poly Pomona", "CSU", 34.0572, -117.8210, "CPP"),
    ("Sacramento State", "CSU", 38.5610, -121.4241, "Sac State"),
    ("CSU San Bernardino", "CSU", 34.1814, -117.3230, "CSUSB"),
    ("San Diego State", "CSU", 32.7757, -117.0719, "SDSU"),
    ("San Francisco State", "CSU", 37.7219, -122.4782, "SFSU"),
    ("San José State", "CSU", 37.3352, -121.8811, "SJSU"),
    ("Cal Poly San Luis Obispo", "CSU", 35.3050, -120.6625, "Cal Poly"),
    ("CSU San Marcos", "CSU", 33.1300, -117.1600, "CSUSM"),
    ("Sonoma State", "CSU", 38.3404, -122.6742, "SSU"),
    ("CSU Stanislaus (Turlock)", "CSU", 37.5230, -120.8567, "Stanislaus"),
]
camp = pd.DataFrame(rows, columns=["name", "system", "lat", "lon", "abbr"])

# --- Prepare campus XY in the SAME coordinate system as counties ---
if is_projected_like_3857:
    # Counties are in meters, likely EPSG:3857. Project lon/lat -> Web Mercator manually.
    R = 6378137.0
    lon_rad = np.radians(camp["lon"].to_numpy())
    lat_rad = np.radians(camp["lat"].to_numpy())
    camp_x = R * lon_rad
    camp_y = R * np.log(np.tan(np.pi/4.0 + lat_rad/2.0))
    label_dx = 12000.0   # ~12 km to the right for labels
else:
    # Counties are already in degrees; use lon/lat directly.
    camp_x = camp["lon"].to_numpy()
    camp_y = camp["lat"].to_numpy()
    label_dx = 0.08      # small degree offset for labels

is_uc = (camp["system"].values == "UC")
is_csu = (camp["system"].values == "CSU")

# --- Plot heatmap ---
fig, ax = plt.subplots(figsize=(6, 8))

map = g.plot(
    column="transfer_factor_proximity",
    scheme="Quantiles", k=4,  # requires mapclassify
    edgecolor="black", linewidth=0.3,
    legend=True,
    figsize=(6, 8), cmap="Blues",
    ax=ax,
    legend_kwds={
        "title": "Share Citing Proximity",
        "loc": "lower left",
        "frameon": True,
        "fontsize": 8,
        "ncol": 1
    }
)
mapleg = ax.get_legend()
# --- Overlay campuses ---
# --- colors ---
uc_color = "#FFD200"   # orange
csu_color = "#CC0B2A"   # red

# --- draw markers (with white outlines for contrast) ---
ax.scatter(
    camp_x[is_uc], camp_y[is_uc],
    marker="^", s=52, zorder=5,
    facecolors=uc_color, edgecolors="white", linewidths=0.7,
    label="UC (10)"
)
ax.scatter(
    camp_x[is_csu], camp_y[is_csu],
    marker="o", s=44, zorder=5,
    facecolors=csu_color, edgecolors="white", linewidths=0.7,
    label="CSU (23)"
)
# ax.scatter(camp_x[is_uc],  camp_y[is_uc],  marker="^", s=36, label="UC (10)")
# ax.scatter(camp_x[is_csu], camp_y[is_csu], marker="o", s=28, label="CSU (23)")

marker_handles = [
    Line2D([0], [0], marker="^", linestyle="None",
           markerfacecolor=uc_color, markeredgecolor="white",
           markeredgewidth=0.7, markersize=7, label="UC"),
    Line2D([0], [0], marker="o", linestyle="None",
           markerfacecolor=csu_color, markeredgecolor="white",
           markeredgewidth=0.7, markersize=7, label="CSU")
]

# Optional short labels
# label style (white halo makes text readable over any fill)
halo = [pe.withStroke(linewidth=2, foreground="white")]

uc_label = dict(fontsize=6, color=uc_color,
                path_effects=halo)      # match UC marker
csu_label = dict(fontsize=6, color=csu_color,
                 path_effects=halo)     # match CSU marker

for x, y, abbr, sys in zip(camp_x, camp_y, camp["abbr"], camp["system"]):
    style = uc_label if sys == "UC" else csu_label
    ax.text(x + label_dx, y, abbr, **style)

ax.set_aspect("equal", adjustable="box")
ax.legend(handles=marker_handles, loc="upper right",
          frameon=True, title="Campuses")
ax.add_artist(mapleg)
ax.set_axis_off()
plt.tight_layout()
out_path = "proximity_overlay.png"
plt.savefig(out_path, bbox_inches='tight', dpi=300)
plt.show()
plt.show()
