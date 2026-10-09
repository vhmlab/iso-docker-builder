# Generic mkimage profile: standard ISO + every package in the recipe's world file.
profile_recipe() {
	profile_standard
	profile_abbrev="recipe"
	title="Recipe image"
	desc="Alpine standard plus the packages and config of a build.sh recipe"
	apks="$(echo $apks $(cat /in/world) | tr ' ' '\n' | sort -u | tr '\n' ' ')"
	apkovl="genapkovl-recipe.sh"
}
