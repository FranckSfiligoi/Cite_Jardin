
model naturaNV5

//to do list :
// continuité (trame verte/bleu)
//diminution impact riviere secheresse
//augmenter impact chgt clim
// impact de l'eau sur berge et ripisile ?
//

global
{
	
	float time_step <-1 #month;
	float cell_size<-100#m;
	float var_cell_w<-cell_size;
	float var_cell_h<-cell_size;
	bool climate_change_activated<-true;
	bool update_event<-false;
	bool save_data<-true;
	string new_event;
	float event_val<-0.01;
	
	date starting_date <- date([2022, 1, 2, 14, 0, 0]);
	float simulation_duration<-28 #year;
	shape_file building_shapefile <- shape_file("../gis/buildings_marseille.shp");
	shape_file road_shapefile <- shape_file("../gis/roads_marseille.shp");
	shape_file water_shapefile <- shape_file("../generated/objects/AixCoursdEau.shp");
	shape_file nature_shp <-shape_file("../generated/objects/nature.shp");
//	shape_file nature_shp <-shape_file("../generated/objects/Hanovre/nature.shp");
//	shape_file nature_shp <-shape_file("../generated/objects/Lyon/nature.shp");
//	shape_file nature_shp <-shape_file("../generated/objects/Marseille/nature.shp");
//	shape_file nature_shp <-shape_file("../generated/objects/Nantes/nature.shp");

	
//	float distance_impact_nat1<-50#m;
//	float distance_impact_nat2<-500#m;
	float distance_impact_nat1<-50#m;
	float distance_impact_nat2<-100#m;
	float dn0<-1.0;
	float dn1<-0.1;
	float dn2<-0.05;
	float dn3<-0.01;
	float dn4<-0.001;
	
	float normal_use<-0.001;
	
	float coef_dist<-100#m/distance_impact_nat2;
	
	/*Nature technisiste ; 1: Allée d'arbres ; 2 : Gestion traditionnelle ; 3 : Berge aménagée
				// 4 : Agriculture urbaine ; 5 : Forêt urbaine, 6:Gestion différenciée
				// 7 : Ripisylve sauvage , 8 : Friche renaturée
	*/
	
	
	geometry shape <- envelope(building_shapefile);
		
	file indic_people <- csv_file("../includes/indic_people.csv",";");
	matrix data_indic_people <- matrix(indic_people);
	
	
	//variables environementales au tour

	float temperature;
	float rain;
	float wind;

	int flood_now;
	int storm_now;
	int warm_now;
	int dry_now;
	
	float nature_area;
	int pollution_ind;
	float pollution_lvl;
	
	string narrative_event;
	
	float coeff_pol<-0.15;
	float coeff_sound<-0.003;
	float coeff_soil<-0.15;
	float coeff_warm<-0.15;
	
	float coeff_gentrification<-0.1;
	float coeff_maint_cost<-0.1;
	float coeff_urban_space<-0.1;
	float coeff_well_being<-0.1;
	float coeff_amenity<-0.1;
	float coeff_recreat<-0.1;
	float coeff_access<-0.1;
	float coeff_prod<-0.1;
	float coeff_soc<-0.1;
	float coeff_autonomy<-0.1;
	float coeff_biomass<-0.1;
	float coeff_abund<-0.1;
	float coeff_biodiv<-0.1;
	
	

	list<float> aver_temp<-[7.69,8.7,10.89,12.95,16.56,20.36,23.23,23.73,20.07,15.97,11.83,8.84]; 
	list<float> incr_temp<-[0.04,0.04,0.06,0.06,0.06,0.08,0.08,0.08,0.06,0.06,0.06,0.04];
	
	list<float> aver_air_qual<-[4.69,4.61,4.85,5.08,5.5,4.93,4.96,5.14,5.11,5.2,5.35,4.76]; 
	list<float> incr_air_qual<-[-0.1,-0.1,-0.1,-0.1,-0.1,-0.1,-0.1,-0.1,-0.1,-0.1,-0.1,-0.1];
		
	
	
	
	list<float> aver_rain<-[35,18,16,54,39,16,7,20,51,110,120,57.0]; 
	list<float> max_wind<-[52,47,54,54,51,51,44,50,50,51,51,49.0]; 
	
	list<float> inc_proba_storm<-[0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0]; 
	list<float> inc_proba_warm1<-[0.0,0.0,0.01,0.01,0.01,0.03,0.03,0.03,0.0,0.0,0.0,0.0]; 
	list<float> inc_proba_warm2<-[0.0,0.0,0.0,0.0,0.0,0.02,0.02,0.02,0.0,0.0,0.0,0.0]; 
	list<float> inc_proba_dry<-[0.005,0.005,0,0,0,0.01,0.01,0.01,0.0,0.0,0.0,0.005]; 
	
	list<float> proba_storm<-[0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.05,0.05,0.0,0.0]; 
	list<float> proba_warm1<-[0.0,0.0,0.0,0.0,0.0,0.05,0.1,0.2,0.05,0.0,0.0,0.0]; 
	list<float> proba_warm2<-[0.0,0.0,0.0,0.0,0.0,0.0,0.05,0.1,0.0,0.0,0.0,0.0]; 
	list<float> proba_dry<-[0.13,0.13,0.1,0.1,0.1,0.17,0.2,0.24,0.17,0.07,0.03,0.1]; 
	

	int budget<-3;
	//float cst_bud<-1802.39;
	
	float coeff_ah<-0.0015;
	float coeff_auto_rep<-0.0001;  //5
	
	float coeff_dry<-0.02;
	float coeff_storm<-0.02;
	float coeff_flood<-0.005;	
	float coeff_pollution<-0.005;
	
	float coeff_quality<-0.1;
	float coeff_sat<-0.1;
	
	
	//Criteres et indicateur
	//l’état de santé des espaces de nature
	float nature_state;
	
	//La satisfaction des habitants
	float satisfaction;
	
	
	//La qualité de l’environnement
	float nature_quality;
	
	
	
	//variables et données
	float environment;
	
	float pollution;
	float air_pollution;
	float water_pollution;
	float soil_pollution;
	float sound_pollution;
	list<int> air_pollution_nature<-[1,1,0,0,0,2,0,2,1];
	list<int> water_pollution_nature<-[0,-1,-2,-1,0,0,1,2,0];
	list<int> soil_pollution_nature<-[0,-2,-2,-1,0,0,1,1,2];
	list<int> sound_pollution_nature<-[1,1,0,-2,0,2,0,1,0];

	list<int> refresh_nature<-[1,1,0,1,1,0,1,2,2];
	
	float risk;
	float flood;
	float dryness;
	float city_warming;
	float storm;
	float ground_slope;
	list<int> flood_nature<-[0,0,0,2,0,0,0,1,0];
	list<int> dryness_nature<-[0,0,0,1,0,1,0,2,0];
	list<int> city_warming_nature<-[2,1,1,1,0,2,2,2,1];
	list<int> storm_nature<-[0,1,0,0,-1,2,1,2,0];
	list<int> ground_slope_nature<-[0,0,0,0,0,2,1,2,0];
	list<int> flood_people;
	list<int> dryness_people;
	list<int> city_warming_people;
	list<int> storm_people;
	list<int> ground_slope_people;
	
	
	
	float ecosystem;
	
	float functionnality;
	float autonomy;
	float biomass;
	float abundance;
	float biodiversity;
	list<int> autonomy_nature<-[-1,-1,0,0,-1,1,1,2,2];
	list<int> biomass_nature<-[0,0,1,1,0,2,1,2,0];
	list<int> abundance_nature<-[0,0,-1,0,-1,2,1,2,1];
	list<int> biodiversity_nature<-[0,0,-1,0,-1,1,2,2,2];
	list<int> autonomy_people;
	list<int> biomass_people;
	list<int> abundance_people;
	list<int> biodiversity_people;
	
	float resilience;
	float dry_resilience;
	float storm_resilience;
	float flood_resilience;
	float pollution_resilience;
	float visitation_resilience;
	list<int> dry_resilience_nature<-[-1,-1,-1,-2,0,-1,0,-2,1];
	list<int> storm_resilience_nature<-[0,-1,0,0,0,-1,1,-1,1];
	list<int> flood_resilience_nature<-[0,0,-1,1,-1,0,0,1,0];
	list<int> pollution_resilience_nature<-[0,-1,0,0,-1,-1,1,1,2];
	list<int> visitation_resilience_nature<-[0,0,0,0,0,-1,0,-1,0];
	list<int> dry_resilience_people;
	list<int> storm_resilience_people;
	list<int> flood_resilience_people;
	list<int> pollution_resilience_people;
	list<int> visitation_resilience_people;
	
	float social;
	
	float externalities;
	float gentrification;
	float urban_space;
	float maintenance_cost;
	list<int> gentrification_nature<-[-2,0,-1,-2,-1,0,0,1,1];
	list<int> urban_space_nature<-[0,0,-1,1,1,-2,-1,-1,1];
	list<int> maintenance_cost_nature<-[-2,-1,-2,-1,1,0,0,0,1];
	list<float> maintenance_coef_nature<-[1,0.5,0.5,1,3,0.2,0.3,0,0];
	list<int> gentrification_people;
	list<int> urban_space_people;
	list<int> maintenance_cost_people;
		/*Nature technisiste ; 1: Allée d'arbres ; 2 : Gestion traditionnelle ; 3 : Berge aménagée
				// 4 : Agriculture urbaine ; 5 : Forêt urbaine, 6:Gestion différenciée
				// 7 : Ripisylve sauvage , 8 : Friche renaturée
	*/
	
	//social_need[0]
	
	float social_function;
	float well_being;
	float amenity;
	float recreational;
	float accessibility;
	float production;
	float sociability;
	list<int> well_being_nature<-[1,1,1,1,1,2,2,2,1];
	list<int> amenity_nature<-[1,1,2,2,0,0,-1,-2,-2];
	list<int> recreational_nature<-[0,0,2,1,-1,0,2,-2,-1];
	list<int> accessibility_nature<-[0,0,2,2,0,1,1,-2,-1];
	list<int> production_nature<-[-2,0,-2,-1,2,1,0,0,1];
	list<int> sociability_nature<-[0,0,1,0,2,1,1,-1,1];
	list<int> well_being_people;
	list<int> amenity_people;
	list<int> recreational_people;
	list<int> accessibility_people;
	list<int> production_people;
	list<int> sociability_people;
	
	
	
	
	float max_value;
	float min_value;
	
	init {
	step<-time_step;
	//budget<-cst_bud*world.shape.area #m/1000;
	

	//write "budget : "+budget;
	
	create building from: building_shapefile {
		
		//type d'habitat
		if flip(0.167) {type<-0;}
				else {type<-1;}		
			
		if type=0 {nb_inhabitant<-1+rnd(3);}
		if type=1 {nb_inhabitant<-round(shape.area/15);}
		
	}

	create nature from: nature_shp;

	
	create water from: water_shapefile;
	
	

	
	
	ask building {
		loop it from:1 to:nb_inhabitant{
		create people {
			location<-any_location_in(myself.shape);
			my_building<-myself;
		}	
		}
		
	}
	
		create road from: road_shapefile {
		if not (self overlaps world) {
				do die;
			}
			
			}
			
			ask road {
			do 	breakdown_segment;
	do breakdown_distance;
			
			}
		nature_area<-nature sum_of(each.shape.area);
	

	do define_people_profile;
	ask people {do compute_social_need;}
	do compute_nature_charac;
	ask cell {do init_cell;}
	do compute_indicators;

if save_data {save ["***","***","***"] to: "../results/indicators.csv" format:"csv" rewrite:false;}
	}
//Fin du Init


reflex update_weather {
	temperature<-aver_temp[current_date.month-1]-2+rnd(4);
	rain<-aver_rain[current_date.month-1]*(0.5+rnd(100)/100);
	wind<-max_wind[current_date.month-1]*(0.5+rnd(100)/100);
	do compute_pollution_level;
	storm_now<-0;
	warm_now<-0;
	dry_now<-0;
	new_event<-"";
	
	if flip(proba_storm[current_date.month-1]) {
		storm_now<-max(1,min(5,1+int((wind-60)/3)));
		write "Tempête d'intensité "+storm_now+"("+string(current_date, "'Mois : 'MM' Année : 'yyyy")+")";
	}
	if flip(proba_warm1[current_date.month-1])    {
		warm_now<-max(1,min(3,1+int((temperature-25)/5)));
		write "Canicule d'intensité "+warm_now+"("+string(current_date, "'Mois : 'MM' Année : 'yyyy")+")";
	new_event<-new_event+ " ; Canicule d'intensité "+warm_now;
	}
	
	if flip(proba_warm2[current_date.month-1])    {
		warm_now<-max(1,min(5,1+int((temperature-25)/3)));
		write "Canicule d'intensité "+warm_now+"("+string(current_date, "'Mois : 'MM' Année : 'yyyy")+")";
	new_event<-new_event+ " ; Canicule d'intensité "+warm_now;
	}
	
	if  flip(proba_dry[current_date.month-1]) {
		dry_now<-max(1,min(5,1+int((15-rain)/2)));
		write "Sécheresse d'intensité "+dry_now+"("+string(current_date, "'Mois : 'MM' Année : 'yyyy")+")";
	new_event<-new_event+ " ; Sécheresse d'intensité "+dry_now;
	}
	string mnth;
	if 	storm_now+warm_now+dry_now>0 {
		do hazard_on_nature;
		if current_date.month=1 {mnth<-"janvier";}
		if current_date.month=2 {mnth<-"février";}
		if current_date.month=3 {mnth<-"mars";}
		if current_date.month=4 {mnth<-"avril";}
		if current_date.month=5 {mnth<-"mai";}
		if current_date.month=6 {mnth<-"juin";}
		if current_date.month=7 {mnth<-"juillet";}
		if current_date.month=8 {mnth<-"août";}
		if current_date.month=9 {mnth<-"septembre";}
		if current_date.month=10 {mnth<-"octobre";}
		if current_date.month=11 {mnth<-"novembre";}
		if current_date.month=12 {mnth<-"décembre";}
	}
	
	if warm_now>0 {
		string intens;
		if warm_now=1 {intens<-"de faible intensité";}
		if warm_now=2 {intens<-"de moyenne intensité";}
		if warm_now=3 {intens<-"d'assez forte intensité";}
		if warm_now=4 {intens<-"de très forte  intensité";}
		if warm_now=5 {intens<-"d'intensité extrême";}
		new_event<-"Canicule "+intens+" ("+mnth+ " "+current_date.year+")";		
	}
	
		
	if dry_now>0 {
		string intens;
		if dry_now=1 {intens<-"de faible intensité";}
		if dry_now=2 {intens<-"de moyenne intensité";}
		if dry_now=3 {intens<-"d'assez forte intensité";}
		if dry_now=4 {intens<-"de très forte  intensité";}
		if dry_now=5 {intens<-"d'intensité extrême";}
		if warm_now=0 {new_event<-"Sécheresse "+intens+" ("+mnth+ " "+current_date.year+")";		
	} else {new_event<-new_event+" ; Sécheresse "+intens+" ("+mnth+ " "+current_date.year+")";		
	}
	
	}
	
	
		
	if storm_now>0 {
		string intens;
		if storm_now=1 {intens<-"de faible intensité";}
		if storm_now=2 {intens<-"de moyenne intensité";}
		if storm_now=3 {intens<-"d'assez forte intensité";}
		if storm_now=4 {intens<-"de très forte  intensité";}
		if storm_now=5 {intens<-"d'intensité extrême";}
		if warm_now+dry_now=0 {
			new_event<-"Tempête "+intens+" ("+mnth+ " "+current_date.year+")";		
		} else {
		new_event<-new_event+ " ; Tempête "+intens+" ("+mnth+ " "+current_date.year+")";		
	}}
	
		if pollution_lvl>0.5 {
		string intens;
		intens<-"de faible intensité";
		if pollution_lvl>0.6 {intens<-"de moyenne intensité";}
		if pollution_lvl>0.7 {intens<-"d'assez forte intensité";}
		if pollution_lvl>0.8 {intens<-"de très forte  intensité";}
		if pollution_lvl>0.9 {intens<-"d'intensité extrême";}
		if warm_now+dry_now=0 {
			new_event<-"Pollution "+intens+" ("+mnth+ " "+current_date.year+")";		
		} else {
		new_event<-new_event+ " ; Pollution"+intens+" ("+mnth+ " "+current_date.year+")";		
	}}
	
	
	do nature_self_maintenance;
	do human_on_nature;
	do compute_indicators;
	ask nature {do update_color;}
}




reflex climate_change when:every(12#cycle)  and climate_change_activated  {
	write "new year";
	if save_data {
	save [nature_state, nature_quality,satisfaction] to: "../results/indicators.csv" format:"csv" rewrite:false;
	}
	
	loop ite from:0 to:length(aver_temp)-1 {
		aver_temp[ite]<-aver_temp[ite]+incr_temp[ite];
		aver_air_qual[ite]<-aver_air_qual[ite]+incr_air_qual[ite];
		proba_storm[ite]<- proba_storm[ite]+inc_proba_storm[ite];
		proba_warm1[ite]<-proba_warm1[ite]+inc_proba_warm1[ite];
		proba_warm2[ite]<-proba_warm2[ite]+inc_proba_warm2[ite];
		proba_dry[ite]<-proba_dry[ite]+inc_proba_dry[ite];
		
		
	}
	

	
	
}


reflex end_simu when:(time>(simulation_duration)){
	write "Fin de la simulation";

	do pause;
}


//compute pollution level
action compute_pollution_level {


	pollution_lvl<-(6-aver_air_qual[current_date.month-1])/4;
	//if temperature>20 {pollution_lvl<-pollution_lvl+(temperature-20)/10;}
	//if temperature<10 {pollution_lvl<-pollution_lvl+(10-temperature)/10;}	
	pollution_lvl<-max(0,min(1,pollution_lvl-wind/100));
	pollution_ind<-5;
	if pollution_lvl<0.8 {pollution_ind<-4;} 
	if pollution_lvl<0.6 {pollution_ind<-3;} 
	if pollution_lvl<0.4 {pollution_ind<-2;} 
	if pollution_lvl<0.2 {pollution_ind<-1;} 
	if pollution_lvl<0.05 {pollution_ind<-0;} 
}



//pression environnementale
action hazard_on_nature {
	ask nature {do face_hazard;}
}


//l'auto-entretien des espaces de nature ; 
action nature_self_maintenance {
	ask nature {do self_maintenance;}
}

//l’action humaine directe sur les espaces de nature ;
action human_on_nature {
	ask nature {
	//normal use
	state<-state-normal_use;
	//	write "maint : " +maintenance_coef*bud_inv/tot_ha;
	//maintenance
		state<-min(1,state+maintenance_coef*budget*coeff_ah);
	}	
	
	
	
}




action define_people_profile {
	float al;
	ask people {
		//type d'habitat
		house_type<-my_building.type;
		
		//nb de pièces
		if house_type=0 {house_room<-round((my_building.shape.area-15)/10);}
		else {
			al<-rnd(10000)/10000;
			if al<0.294{house_room<-2;}
			else { if al<(0.294+0.588) {house_room<-3;}
				else {house_room<-5;}
			}
		}
		
		//voiture
		if house_type=0 {has_car<-flip(0.873);}
		if house_type=1 {has_car<-flip(0.639);}
		
		
		//age
		al<-rnd(10000)/10000;
		if al<0.183{age<-0;}
			else { if al<(0.183+0.064) {age<-1;}
				else { if al<(0.183+0.064+0.244) {age<-2;}
					else { if al<(0.183+0.064+0.244+0.264) {age<-3;}
						else{age<-4;}
					}
				}
			}
			
			
		//genre
		if flip(0.473) {gender<-0;} else {gender<-1;}	
		
		//mobility	
		if age<4 {limited_mobility<-flip(0.013);}
		else {limited_mobility<-flip(0.124);}	
		
		//category
		category<-rnd(3);
		
		//importance
		al<-rnd(10000)/10000;
		if al<0.6 {importance<-0;}
			else {if al<0.9 {importance<-1;}
				else {importance<-2;}
			}
		
		//connaissance
		al<-rnd(10000)/10000;
		if al<0.6 {knowledge<-0;}
			else {if al<0.9 {knowledge<-1;}
				else {knowledge<-2;}
			}
								
	}			

}




action inform_on_population {
	int nb_p<-length(people);
	float ho<-with_precision(length(people where (each.gender=0))/length(people)*100,2);
	float fe<-with_precision(length(people where (each.gender=1))/length(people)*100,2);
	float je<-with_precision(length(people where (each.age=0))/length(people)*100,2);
	float ad<-with_precision(length(people where (each.age=1))/length(people)*100,2);
	float pa<-with_precision(length(people where (each.age=2))/length(people)*100,2);
	float se<-with_precision(length(people where (each.age=3))/length(people)*100,2);
	float vi<-with_precision(length(people where (each.age=4))/length(people)*100,2);
	float mr<-with_precision(length(people where (each.limited_mobility))/length(people)*100,2);
	float vo<-with_precision(length(people where (each.has_car))/length(people)*100,2);
	float ma<-with_precision(length(people where (each.house_type=0))/length(people)*100,2);
	
	
	write("************* Population *************");
	write("Nb habitants : "+nb_p);
	write("% homme : "+ho);
	write("% femme : "+fe);
	write("% -15 ans: "+je);
	write("% 15-19 ans: "+ad);
	write("% 20-59 ans (parent) : "+pa);
	write("% 20-59 ans (sans enfant) : "+se);
	write("% +60 ans: "+vi);
	write("% mobilité réduite : "+mr);
	write("% a une voiture : "+vo);
	write("% vis en maison : "+ma);
	write ("*************************************");
}


action compute_indicators {
	ask cell{do reinitiate_cell_contibu;}
	ask nature {
		ask my_cell {
		float dn<-dn0;
		air_pollution_cell<-air_pollution_cell+myself.air_pollution*myself.size_level*myself.state^2*dn*coeff_pol*coef_dist;
		sound_pollution_cell<-sound_pollution_cell+(myself.sound_pollution*myself.size_level*myself.state^2*dn*coeff_sound)*coef_dist;
		water_pollution_cell<-water_pollution_cell+(myself.water_pollution*myself.size_level*myself.state^2* dn*coeff_soil)*coef_dist;
		soil_pollution_cell<-soil_pollution_cell+(myself.soil_pollution*myself.size_level*myself.state^2* dn^3*coeff_soil)*coef_dist;
		refresh_cell<-refresh_cell+(myself.refresh*myself.size_level*myself.state^2* dn*coeff_warm)*coef_dist;
		gentrification_cell<-gentrification_cell+(myself.gentrification*myself.state^2*dn*coeff_gentrification)*coef_dist;
	 	maintenance_cost_cell<-maintenance_cost_cell+(myself.maintenance_cost*myself.size_level*myself.state^2*dn*coeff_maint_cost)*coef_dist;
		urban_space_cell<-urban_space_cell+(myself.urban_space*myself.state^2*myself.size_level*dn*coeff_urban_space)*coef_dist;	
		
		well_being_cell<-well_being_cell+(myself.well_being*myself.size_level*myself.state^2*dn*coeff_well_being)*coef_dist;
		amenity_cell<-amenity_cell+(myself.amenity*myself.state^2*myself.size_level*dn*coeff_amenity)*coef_dist;	
		recreational_cell<-recreational_cell+(myself.recreational*myself.size_level*myself.state^2*dn*coeff_recreat)*coef_dist;
		accessibility_cell<-accessibility_cell+(myself.accessibility*dn*myself.state^2*coeff_access)*coef_dist;	
		production_cell<-production_cell+(myself.production*myself.size_level*myself.state^2*dn*coeff_prod)*coef_dist;
		sociability_cell<-sociability_cell+(myself.sociability*myself.state^2*myself.size_level*dn*coeff_soc)*coef_dist;	
		
		autonomy_cell<-autonomy_cell+(myself.autonomy*myself.size_level*myself.state^2*dn*coeff_autonomy)*coef_dist;
		biomass_cell<-biomass_cell+(myself.biomass*dn*myself.state^2*coeff_biomass)*coef_dist;	
		abundance_cell<-abundance_cell+(myself.abundance*myself.size_level*myself.state^2*dn*coeff_abund)*coef_dist;
		biodiversity_cell<-biodiversity_cell+(myself.biodiversity*myself.state^2*myself.size_level*dn*coeff_biodiv)*coef_dist;	
		
		}
		
		ask cell_dist1 {
		float dn<-dn1;
		air_pollution_cell<-air_pollution_cell+myself.air_pollution*myself.size_level*myself.state^2*dn*coeff_pol*coef_dist;
		sound_pollution_cell<-sound_pollution_cell+(myself.sound_pollution*myself.size_level*myself.state^2*dn*coeff_sound)*coef_dist;
		water_pollution_cell<-water_pollution_cell+(myself.water_pollution*myself.size_level*myself.state^2* dn*coeff_soil)*coef_dist;
		soil_pollution_cell<-soil_pollution_cell+(myself.soil_pollution*myself.size_level*myself.state^2* dn^3*coeff_soil)*coef_dist;
		refresh_cell<-refresh_cell+(myself.refresh*myself.size_level*myself.state^2* dn*coeff_warm)*coef_dist;
		gentrification_cell<-gentrification_cell+(myself.gentrification*myself.state^2*dn*coeff_gentrification)*coef_dist;
	 	maintenance_cost_cell<-maintenance_cost_cell+(myself.maintenance_cost*myself.size_level*myself.state^2*dn*coeff_maint_cost)*coef_dist;
		urban_space_cell<-urban_space_cell+(myself.urban_space*myself.state^2*myself.size_level*dn*coeff_urban_space)*coef_dist;	
		
		well_being_cell<-well_being_cell+(myself.well_being*myself.size_level*myself.state^2*dn*coeff_well_being)*coef_dist;
		amenity_cell<-amenity_cell+(myself.amenity*myself.state^2*myself.size_level*dn*coeff_amenity)*coef_dist;	
		recreational_cell<-recreational_cell+(myself.recreational*myself.size_level*myself.state^2*dn*coeff_recreat)*coef_dist;
		accessibility_cell<-accessibility_cell+(myself.accessibility*dn*myself.state^2*coeff_access)*coef_dist;	
		production_cell<-production_cell+(myself.production*myself.size_level*myself.state^2*dn*coeff_prod)*coef_dist;
		sociability_cell<-sociability_cell+(myself.sociability*myself.state^2*myself.size_level*dn*coeff_soc)*coef_dist;	
		
		autonomy_cell<-autonomy_cell+(myself.autonomy*myself.size_level*myself.state^2*dn*coeff_autonomy)*coef_dist;
		biomass_cell<-biomass_cell+(myself.biomass*dn*myself.state^2*coeff_biomass)*coef_dist;	
		abundance_cell<-abundance_cell+(myself.abundance*myself.size_level*myself.state^2*dn*coeff_abund)*coef_dist;
		biodiversity_cell<-biodiversity_cell+(myself.biodiversity*myself.state^2*myself.size_level*dn*coeff_biodiv)*coef_dist;	
					}
		
		ask cell_dist2 {
		float dn<-dn2;
		air_pollution_cell<-air_pollution_cell+myself.air_pollution*myself.size_level*myself.state^2*dn*coeff_pol*coef_dist;
		sound_pollution_cell<-sound_pollution_cell+(myself.sound_pollution*myself.size_level*myself.state^2*dn*coeff_sound)*coef_dist;
		water_pollution_cell<-water_pollution_cell+(myself.water_pollution*myself.size_level*myself.state^2* dn*coeff_soil)*coef_dist;
		soil_pollution_cell<-soil_pollution_cell+(myself.soil_pollution*myself.size_level*myself.state^2* dn^3*coeff_soil)*coef_dist;
		refresh_cell<-refresh_cell+(myself.refresh*myself.size_level*myself.state^2* dn*coeff_warm)*coef_dist;
		gentrification_cell<-gentrification_cell+(myself.gentrification*myself.state^2*dn*coeff_gentrification)*coef_dist;
	 	maintenance_cost_cell<-maintenance_cost_cell+(myself.maintenance_cost*myself.size_level*myself.state^2*dn*coeff_maint_cost)*coef_dist;
		urban_space_cell<-urban_space_cell+(myself.urban_space*myself.state^2*myself.size_level*dn*coeff_urban_space)*coef_dist;	
		
		well_being_cell<-well_being_cell+(myself.well_being*myself.size_level*myself.state^2*dn*coeff_well_being)*coef_dist;
		amenity_cell<-amenity_cell+(myself.amenity*myself.state^2*myself.size_level*dn*coeff_amenity)*coef_dist;	
		recreational_cell<-recreational_cell+(myself.recreational*myself.size_level*myself.state^2*dn*coeff_recreat)*coef_dist;
		accessibility_cell<-accessibility_cell+(myself.accessibility*dn*myself.state^2*coeff_access)*coef_dist;	
		production_cell<-production_cell+(myself.production*myself.size_level*myself.state^2*dn*coeff_prod)*coef_dist;
		sociability_cell<-sociability_cell+(myself.sociability*myself.state^2*myself.size_level*dn*coeff_soc)*coef_dist;	
		
		autonomy_cell<-autonomy_cell+(myself.autonomy*myself.size_level*myself.state^2*dn*coeff_autonomy)*coef_dist;
		biomass_cell<-biomass_cell+(myself.biomass*dn*myself.state^2*coeff_biomass)*coef_dist;	
		abundance_cell<-abundance_cell+(myself.abundance*myself.size_level*myself.state^2*dn*coeff_abund)*coef_dist;
		biodiversity_cell<-biodiversity_cell+(myself.biodiversity*myself.state^2*myself.size_level*dn*coeff_biodiv)*coef_dist;	
				}
		
		ask cell_dist3 {
		float dn<-dn3;
			air_pollution_cell<-air_pollution_cell+myself.air_pollution*myself.size_level*myself.state^2*dn*coeff_pol*coef_dist;
		sound_pollution_cell<-sound_pollution_cell+(myself.sound_pollution*myself.size_level*myself.state^2*dn*coeff_sound)*coef_dist;
		water_pollution_cell<-water_pollution_cell+(myself.water_pollution*myself.size_level*myself.state^2* dn*coeff_soil)*coef_dist;
		soil_pollution_cell<-soil_pollution_cell+(myself.soil_pollution*myself.size_level*myself.state^2* dn^3*coeff_soil)*coef_dist;
		refresh_cell<-refresh_cell+(myself.refresh*myself.size_level*myself.state^2* dn*coeff_warm)*coef_dist;
		gentrification_cell<-gentrification_cell+(myself.gentrification*myself.state^2*dn*coeff_gentrification)*coef_dist;
	 	maintenance_cost_cell<-maintenance_cost_cell+(myself.maintenance_cost*myself.size_level*myself.state^2*dn*coeff_maint_cost)*coef_dist;
		urban_space_cell<-urban_space_cell+(myself.urban_space*myself.state^2*myself.size_level*dn*coeff_urban_space)*coef_dist;	
		
		well_being_cell<-well_being_cell+(myself.well_being*myself.size_level*myself.state^2*dn*coeff_well_being)*coef_dist;
		amenity_cell<-amenity_cell+(myself.amenity*myself.state^2*myself.size_level*dn*coeff_amenity)*coef_dist;	
		recreational_cell<-recreational_cell+(myself.recreational*myself.size_level*myself.state^2*dn*coeff_recreat)*coef_dist;
		accessibility_cell<-accessibility_cell+(myself.accessibility*dn*myself.state^2*coeff_access)*coef_dist;	
		production_cell<-production_cell+(myself.production*myself.size_level*myself.state^2*dn*coeff_prod)*coef_dist;
		sociability_cell<-sociability_cell+(myself.sociability*myself.state^2*myself.size_level*dn*coeff_soc)*coef_dist;	
		
		autonomy_cell<-autonomy_cell+(myself.autonomy*myself.size_level*myself.state^2*dn*coeff_autonomy)*coef_dist;
		biomass_cell<-biomass_cell+(myself.biomass*dn*myself.state^2*coeff_biomass)*coef_dist;	
		abundance_cell<-abundance_cell+(myself.abundance*myself.size_level*myself.state^2*dn*coeff_abund)*coef_dist;
		biodiversity_cell<-biodiversity_cell+(myself.biodiversity*myself.state^2*myself.size_level*dn*coeff_biodiv)*coef_dist;	
			}
		
		ask cell_dist4 {
		float dn<-dn4;
			air_pollution_cell<-air_pollution_cell+myself.air_pollution*myself.size_level*myself.state^2*dn*coeff_pol*coef_dist;
		sound_pollution_cell<-sound_pollution_cell+(myself.sound_pollution*myself.size_level*myself.state^2*dn*coeff_sound)*coef_dist;
		water_pollution_cell<-water_pollution_cell+(myself.water_pollution*myself.size_level*myself.state^2* dn*coeff_soil)*coef_dist;
		soil_pollution_cell<-soil_pollution_cell+(myself.soil_pollution*myself.size_level*myself.state^2* dn^3*coeff_soil)*coef_dist;
		refresh_cell<-refresh_cell+(myself.refresh*myself.size_level*myself.state^2* dn*coeff_warm)*coef_dist;
		gentrification_cell<-gentrification_cell+(myself.gentrification*myself.state^2*dn*coeff_gentrification)*coef_dist;
	 	maintenance_cost_cell<-maintenance_cost_cell+(myself.maintenance_cost*myself.size_level*myself.state^2*dn*coeff_maint_cost)*coef_dist;
		urban_space_cell<-urban_space_cell+(myself.urban_space*myself.state^2*myself.size_level*dn*coeff_urban_space)*coef_dist;	
		
		well_being_cell<-well_being_cell+(myself.well_being*myself.size_level*myself.state^2*dn*coeff_well_being)*coef_dist;
		amenity_cell<-amenity_cell+(myself.amenity*myself.state^2*myself.size_level*dn*coeff_amenity)*coef_dist;	
		recreational_cell<-recreational_cell+(myself.recreational*myself.size_level*myself.state^2*dn*coeff_recreat)*coef_dist;
		accessibility_cell<-accessibility_cell+(myself.accessibility*dn*myself.state^2*coeff_access)*coef_dist;	
		production_cell<-production_cell+(myself.production*myself.size_level*myself.state^2*dn*coeff_prod)*coef_dist;
		sociability_cell<-sociability_cell+(myself.sociability*myself.state^2*myself.size_level*dn*coeff_soc)*coef_dist;	
		
		autonomy_cell<-autonomy_cell+(myself.autonomy*myself.size_level*myself.state^2*dn*coeff_autonomy)*coef_dist;
		biomass_cell<-biomass_cell+(myself.biomass*dn*myself.state^2*coeff_biomass)*coef_dist;	
		abundance_cell<-abundance_cell+(myself.abundance*myself.size_level*myself.state^2*dn*coeff_abund)*coef_dist;
		biodiversity_cell<-biodiversity_cell+(myself.biodiversity*myself.state^2*myself.size_level*dn*coeff_biodiv)*coef_dist;	
				}
		
	}

ask cell {do compute_nature_cell_contribu;}
	
	float nsb<-nature_state;
	float sb<-satisfaction;
	float nqb<-nature_quality;
	
	
	//l’état de santé des espaces de nature
	nature_state<- nature sum_of(each.state*each.shape.area)/nature sum_of(each.shape.area);
	
	
	//La satisfaction des habitants
	ask people {do compute_satisfaction;}
	satisfaction<-people mean_of(each.satisfaction);
	
	//La qualité de l’environnement
	ask nature {do compute_quality;}
	nature_quality<- (nature sum_of(each.quality))*coeff_quality/nature_area;
		
	if nsb-nature_state>event_val {update_event<-true;}
	if sb-satisfaction>event_val {update_event<-true;}
	if nqb-nature_quality>event_val {update_event<-true;}
	
	if update_event {
	narrative_event<-new_event;
	update_event<-false;
	}
		
}



action compute_nature_charac {
	air_pollution<- nature sum_of(each.air_pollution);
	water_pollution<-nature sum_of(each.water_pollution);
	soil_pollution<-nature sum_of(each.soil_pollution);
	sound_pollution<-nature sum_of(each.sound_pollution);
	pollution<-mean([air_pollution,water_pollution,soil_pollution,sound_pollution]);

	flood<-nature sum_of(each.flood);
	dryness<-nature sum_of(each.dryness);
	city_warming<-nature sum_of(each.city_warming);
	storm<-nature sum_of(each.storm);
	ground_slope<-nature sum_of(each.ground_slope);
	risk<-mean([flood,dryness,city_warming,storm,ground_slope]);
	
	environment<-mean(pollution,risk);

	gentrification<-nature sum_of(each.gentrification);
	urban_space<-nature sum_of(each.urban_space);
	maintenance_cost<-nature sum_of(each.maintenance_cost);
	externalities<-mean(gentrification,urban_space,maintenance_cost);
	
	
	well_being<-nature sum_of(each.well_being);
	amenity<-nature sum_of(each.amenity);
	recreational<-nature sum_of(each.recreational);
	accessibility<-nature sum_of(each.accessibility);
	production<-nature sum_of(each.production);
	sociability<-nature sum_of(each.sociability);
	social_function<-mean(well_being,amenity,recreational,accessibility,production,sociability);
	
	social<-mean(externalities,social_function);
	
}





}

// ******************* ROAD ********************************

species road
{
	rgb color <- rnd_color(255);
	string type;
	list<cell> my_cells;
	float long;

	action breakdown_segment {
			list<geometry> plr<- to_segments(shape);
			 	loop g over: plr {
				create road {
					shape<-g;
					long<-shape.perimeter/2;
					location<-g.location;
					if not (self overlaps world) {do die;}
					my_cells <- cell overlapping self;
					}
				}
		do die;
		}
		
		
		
	action breakdown_distance {		
			list pr <-points_on(shape,100.0#m);
			loop pi over:pr {
			loop g over: split_at(shape,pi) {
				create road {
					shape<-g;
					long<-shape.perimeter/2;
					location<-g.location;
					if not (self overlaps world) {do die;}
					my_cells <- cell overlapping self;
					}
				}
				do die;
			}
		
	}
	aspect default
	{
		draw shape color: #orange;
	}

}


// ******************* WATER ********************************

species water
{
	string type;
	aspect default
	{
		draw shape color: #blue;
	}

}


// ******************* BUILDING ********************************


species building
{
int type;//0:maison ; 1:appartement
int nb_inhabitant;
	aspect default
	{
		draw shape color: #orange;
	}

}


// ******************* PEOPLE ********************************

species people {
	building my_building;
	cell my_cell;
	rgb color<-#blue;
	int house_type; //0:maison ; 1:appartement
	int house_room;
	bool has_car;
	int age; //0:0-14, 1:15-19, 2:20-59 (parent), 3:20-59(sans enfant), 4:60+
	int gender; //0:homme, 1:femme
	bool limited_mobility;
	int category;// 0:naturaliste, 1:contestatire, 2:ordinaire, 3:démocratique
	int importance; //0:faible, 1:moyenne, 2:fort
	int knowledge; //0:faible, 1:moyenne, 2:fort
	float satisfaction<-0.5;

	
	
	
	list<int> social_need<-[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
	list<float> social_weigth<-[1.0,1.0,1.0,1.0,1.0,
		0.5,0.5,0.5,0.5,
		1.0,1.0,1.0,
		2.0,2.0,2.0,
		1.0,0.5,2.0
	];
	
	/*
	 	 	satisfaction<-satisfaction+social_need[0]*social_weigth[0]*my_cell.air_pollution_cell;
		satisfaction<-satisfaction+social_need[1]*social_weigth[1]*my_cell.water_pollution_cell;
		satisfaction<-satisfaction+social_need[2]*social_weigth[2]*my_cell.soil_pollution_cell;
		satisfaction<-satisfaction+social_need[3]*social_weigth[3]*my_cell.sound_pollution_cell;
		satisfaction<-satisfaction+social_need[4]*social_weigth[4]*my_cell.refresh_cell;
		
		satisfaction<-satisfaction+social_need[9]*social_weigth[5]*my_cell.autonomy_cell;
		satisfaction<-satisfaction+social_need[10]*social_weigth[6]*my_cell.biomass_cell;
		satisfaction<-satisfaction+social_need[11]*social_weigth[7]*my_cell.abundance_cell;
		satisfaction<-satisfaction+social_need[12]*social_weigth[8]*my_cell.biodiversity_cell;
		
	
		satisfaction<-satisfaction+social_need[18]*social_weigth[9]*my_cell.gentrification_cell;
		satisfaction<-satisfaction+social_need[19]*social_weigth[10]*my_cell.urban_space_cell;
		satisfaction<-satisfaction+social_need[20]*social_weigth[11]*my_cell.maintenance_cost_cell;
		* 
		satisfaction<-satisfaction+social_need[21]*social_weigth[12]*my_cell.well_being_cell;
		satisfaction<-satisfaction+social_need[22]*social_weigth[13]*my_cell.amenity_cell;
		satisfaction<-satisfaction+social_need[23]*social_weigth[14]*my_cell.recreational_cell;
		satisfaction<-satisfaction+social_need[24]*social_weigth[15]*my_cell.accessibility_cell;
		satisfaction<-satisfaction+social_need[25]*social_weigth[16]*my_cell.production_cell;
		satisfaction<-satisfaction+social_need[26]*social_weigth[17]*my_cell.sociability_cell;
	 */
	
	init {
		my_cell<-one_of(cell overlapping(self));
		ask my_cell {add myself to:my_people;}
	}
	
	action compute_social_need {
		
		loop it from:0 to:26 {
			social_need[it]<-int(data_indic_people[it,0]);
			if house_type=0 {social_need[it]<-social_need[it]+int(data_indic_people[it,1]);}
			if house_type=1 {social_need[it]<-social_need[it]+int(data_indic_people[it,2]);}
			if house_room<3 {social_need[it]<-social_need[it]+int(data_indic_people[it,3]);}
			if (house_room>=3 and house_room<5)  {social_need[it]<-social_need[it]+int(data_indic_people[it,4]);}
			if house_room>4 {social_need[it]<-social_need[it]+int(data_indic_people[it,5]);}
			if has_car {social_need[it]<-social_need[it]+int(data_indic_people[it,6]);}
			if !has_car {social_need[it]<-social_need[it]+int(data_indic_people[it,7]);}
			if age=0 {social_need[it]<-social_need[it]+int(data_indic_people[it,8]);}
			if age=1 {social_need[it]<-social_need[it]+int(data_indic_people[it,9]);}
			if age=2 {social_need[it]<-social_need[it]+int(data_indic_people[it,10]);}
			if age=3 {social_need[it]<-social_need[it]+int(data_indic_people[it,11]);}
			if age=4 {social_need[it]<-social_need[it]+int(data_indic_people[it,12]);}
			if gender=0 {social_need[it]<-social_need[it]+int(data_indic_people[it,13]);}
			if gender=1 {social_need[it]<-social_need[it]+int(data_indic_people[it,14]);}
			if limited_mobility {social_need[it]<-social_need[it]+int(data_indic_people[it,15]);}
			if !limited_mobility {social_need[it]<-social_need[it]+int(data_indic_people[it,16]);}
			if category=0 {social_need[it]<-social_need[it]+int(data_indic_people[it,17]);}
			if category=1 {social_need[it]<-social_need[it]+int(data_indic_people[it,18]);}
			if category=2 {social_need[it]<-social_need[it]+int(data_indic_people[it,19]);}
			if category=3 {social_need[it]<-social_need[it]+int(data_indic_people[it,20]);}
		}
		
		
	}
	
	action compute_satisfaction {
		
		satisfaction<-0.0;
	 	satisfaction<-satisfaction+social_need[0]*social_weigth[0]*my_cell.air_pollution_cell;
		satisfaction<-satisfaction+social_need[1]*social_weigth[1]*my_cell.water_pollution_cell;
		satisfaction<-satisfaction+social_need[2]*social_weigth[2]*my_cell.soil_pollution_cell;
		satisfaction<-satisfaction+social_need[3]*social_weigth[3]*my_cell.sound_pollution_cell;
		satisfaction<-satisfaction+social_need[4]*social_weigth[4]*my_cell.refresh_cell;
		
		satisfaction<-satisfaction+social_need[9]*social_weigth[5]*my_cell.autonomy_cell;
		satisfaction<-satisfaction+social_need[10]*social_weigth[6]*my_cell.biomass_cell;
		satisfaction<-satisfaction+social_need[11]*social_weigth[7]*my_cell.abundance_cell;
		satisfaction<-satisfaction+social_need[12]*social_weigth[8]*my_cell.biodiversity_cell;
		
	
		satisfaction<-satisfaction+social_need[18]*social_weigth[9]*my_cell.gentrification_cell;
		satisfaction<-satisfaction+social_need[19]*social_weigth[10]*my_cell.urban_space_cell;
		satisfaction<-satisfaction+social_need[20]*social_weigth[11]*my_cell.maintenance_cost_cell;
		satisfaction<-satisfaction+social_need[21]*social_weigth[12]*my_cell.well_being_cell;
		satisfaction<-satisfaction+social_need[22]*social_weigth[13]*my_cell.amenity_cell;
		satisfaction<-satisfaction+social_need[23]*social_weigth[14]*my_cell.recreational_cell;
		satisfaction<-satisfaction+social_need[24]*social_weigth[15]*my_cell.accessibility_cell;
		satisfaction<-satisfaction+social_need[25]*social_weigth[16]*my_cell.production_cell;
		satisfaction<-satisfaction+social_need[26]*social_weigth[17]*my_cell.sociability_cell;

satisfaction<-min(1,max(0,satisfaction*coeff_sat));
	color<-#green;
	if satisfaction<0.8 {color<-#greenyellow;}
	if satisfaction<0.6 {color<-#yellow;}
	if satisfaction<0.4 {color<-#gamaorange;}
	if satisfaction<0.2 {color<-#red;}
		
		
		

	}
	
	
	
		aspect default {
		draw circle(1)  color: color border:#black;
	}
}



// ******************* NATURE ********************************

species nature {
	int type; //0 : Nature technisiste ; 1: Allée d'arbres ; 2 : Gestion traditionnelle ; 3 : Berge aménagée
				// 4 : Agriculture urbaine ; 5 : Forêt urbaine, 6:Gestion différenciée
				// 7 : Ripisylve sauvage , 8 : Friche renaturée
	list<cell> my_cell;
	list<cell> cell_dist1;
	 list<cell> cell_dist2;
	 list<cell> cell_dist3;
	 list<cell> cell_dist4;
	float state<-0.5;
	float quality<-0.5;
	float coeff_qual<-0.8;
	rgb color<-#green;
	rgb color_bord<-#green;
	list<int> col<-[0,255,0];
	float size_level;
	int well_being;
	int amenity;
	int recreational;
	int accessibility;
	int production;
	int sociability;
	int air_pollution;
	int water_pollution;
	int soil_pollution;
	int sound_pollution;
	int refresh;
	int flood;
	int dryness;
	int city_warming;
	int storm;
	int ground_slope;
	int externalities;
	int gentrification;
	int urban_space;
	int maintenance_cost;	
	int functionnality;
	int autonomy;
	int biomass;
	int abundance;
	int biodiversity;
	int resilience;
	int dry_resilience;
	int storm_resilience;
	int flood_resilience;
	int pollution_resilience;
	int visitation_resilience;
	float maintenance_coef;
	bool light<-false;
	bool to_die<-false;
	float continuity;
	float shape_coeff;
	
	init {
	//0 : Nature technisiste ; 1: Allée d'arbres ; 2 : Gestion traditionnelle ; 3 : Berge aménagée
				// 4 : Agriculture urbaine ; 5 : Forêt urbaine, 6:Gestion différenciée
				// 7 : Ripisylve sauvage , 8 : Friche renaturée
	
		if type=0 { color_bord<-#darkcyan;}
		if type=1 { color_bord<-#blueviolet;}
		if type=2 { color_bord<-#slategrey ;}
		if type=3 { color_bord<-#dodgerblue;}
		if type=4 { color_bord<-#gold;}
		if type=5 { color_bord<-#lime ;}
		if type=6 { color_bord<-#green;}
		if type=7 { color_bord<-#darksalmon;}
		if type=8 { color_bord<-#firebrick ;}
	
	 
		
	well_being<-well_being_nature[type];
	amenity<-amenity_nature[type];
	recreational<-recreational_nature[type];
	accessibility<-accessibility_nature[type];
	production<-production_nature[type];
	sociability<-sociability_nature[type];
	air_pollution<-air_pollution_nature[type];
	water_pollution<-water_pollution_nature[type];
	soil_pollution<-soil_pollution_nature[type];
	sound_pollution<-sound_pollution_nature[type];
	flood<-flood_nature[type];
	refresh<-refresh_nature[type];
	dryness<-dryness_nature[type];
	city_warming<-city_warming_nature[type];
	storm<-storm_nature[type];
	ground_slope<-ground_slope_nature[type];
	gentrification<-gentrification_nature[type];
	urban_space<-urban_space_nature[type];
	maintenance_cost<-maintenance_cost_nature[type];	
	autonomy<-autonomy_nature[type];
	biomass<-biomass_nature[type];
	abundance<-abundance_nature[type];
	biodiversity<-biodiversity_nature[type];
	dry_resilience<-dry_resilience_nature[type];
	storm_resilience<-storm_resilience_nature[type];
	flood_resilience<-flood_resilience_nature[type];
	pollution_resilience<-pollution_resilience_nature[type];
	visitation_resilience<-visitation_resilience_nature[type];
	maintenance_coef<-maintenance_coef_nature[type];	
	
	size_level<-shape.area/(distance_impact_nat1^2*3.14);
	//write size_level;
	
	do init_cell_dist;
	}
	
	
	
	action init_cell_dist {
	 list<cell> all_cell<-cell where (each.shape.area>0);
	 my_cell<-cell overlapping(self);
	all_cell<-cell-my_cell;
	list<cell> ct;

		
		ct<-nil;
		ask my_cell {
		add agents_at_distance(distance_impact_nat2/4) of_species cell all:true to:ct;		
	}
		ct<-remove_duplicates(ct);
		ct<-ct-my_cell;
		all_cell<-all_cell-ct;
		cell_dist1<-ct;	
		
		
		
		ct<-nil;
		ask my_cell {
		add agents_at_distance(distance_impact_nat2/3) of_species cell all:true to:ct;		
	}
		ct<-remove_duplicates(ct);
		ct<-ct-my_cell-cell_dist1;
		cell_dist2<-ct;	
		
		
		
		ct<-nil;
		ask my_cell {
		add agents_at_distance(distance_impact_nat2/2) of_species cell all:true to:ct;		
	}
		ct<-remove_duplicates(ct);
		ct<-ct-my_cell-cell_dist1-cell_dist2;
		cell_dist3<-ct;	
		
		
		
		ct<-nil;
		ask my_cell {
		add agents_at_distance(distance_impact_nat2) of_species cell all:true to:ct;			
	}
		ct<-remove_duplicates(ct);
		ct<-ct-my_cell-cell_dist1-cell_dist2-cell_dist3;
		cell_dist4<-ct;	
		
		
		list<nature> nat_dist1<-(nature where (each.size_level>0.5)) at_distance(distance_impact_nat1) ;
		list<nature> nat_dist2<-(nature where (each.size_level>0.5)) at_distance(distance_impact_nat2) ;
		continuity<-1.0+length(nat_dist1)/10+length(nat_dist2)/100;
		shape_coeff<-1.0+shape.area/shape.perimeter/(world.shape.perimeter)*100;
		/*write continuity;
		write shape_coeff;
		write "***";*/
			}
	
	
	action face_hazard {
	float stat_b;
	if dry_resilience+2<dry_now {
		state<-max(0.0,state-(max(0,dry_now-dry_resilience-2)*coeff_dry));
	//	write "haz_dry : "+(dry_now-dry_resilience-2)*coeff_dry;
	}
	if storm_resilience+2<storm_now {
		state<-max(0.0,state-(max(0,storm_now-storm_resilience-2)*coeff_storm));
	 //	write "haz storm : "+(storm_now-storm_resilience)*coeff_storm;
	}
	
	if flood_resilience+2<flood_now{ 
	state<-max(0.0,state-(max(0,flood_now-flood_resilience-2)*coeff_flood));
	//write "haz flo : "+(flood_now-flood_resilience)*coeff_flood;
	}	
	
	
	if pollution_resilience+2<pollution_ind {
		state<-max(0.0,state-(max(0,pollution_ind-pollution_resilience-2)*coeff_pollution));
	//	write "haz pol : "+(pollution_ind*2-pollution_resilience)*coeff_pollution;
	}		
}
	
	
	action self_maintenance {
		state<-max(0,min(1,state+(1+autonomy)*coeff_auto_rep*continuity*shape_coeff*(1+size_level/10))) ;
	//write "self : " +(1+autonomy)*coeff_auto_rep;
	}
	
	action compute_quality {
quality<-mean(3+biomass,3+abundance,3+biodiversity)*state*shape.area*continuity*shape_coeff*coeff_qual;
	}
	
	action update_color {
		list<int> rd<-[255,0,0];
		list<int> cl<-[0,0,0];
	loop i from:0 to:2 {
			cl[i]<-rd[i]*(1-state)+state*col[i];
	}
		color<-rgb(cl[0],cl[1],cl[2]);
	}
	
	
	
			aspect map_base
	{
		if light{draw shape color:#black;}
		else{draw shape color:color_bord ;}
		
		//draw shape color:color border:color_bord width:10#m;
			//	draw ""+state color:#black  font:font("Helvetica", 20, #plain) depth:5;
		
	}


			aspect nature_state
	{
		draw shape color:color border:#black;
	//	draw ""+state color:#black  font:font("Helvetica", 20, #plain) depth:5;
		}
		
		//draw shape color:color border:color_bord width:10#m;
				
		
	
}


// ******************* GRID CELL (ENVIRONNEMENT) ********************************

grid cell neighbors:8 cell_height:var_cell_h cell_width:var_cell_w {
	float altitude<-1.0;
	bool close_river<-false;

	list<nature> close_nature;
	list<float> dist_nature;
	
	float air_pollution_cell;
	float water_pollution_cell;
	float soil_pollution_cell;
	float sound_pollution_cell;
	float refresh_cell;
	list<road> close_road;
	float road_density;
	float building_density;
	float gentrification_cell;
	float urban_space_cell;
	float maintenance_cost_cell;
	float well_being_cell;
	float amenity_cell;
	float recreational_cell;
	float accessibility_cell;
	float production_cell;
	float sociability_cell;
	
	rgb quality_env_color;
	rgb satisfaction_color;
	
	float quality_of_env;
	float satisfaction;
	
	
	
	float autonomy_cell;
	float biomass_cell;
	float abundance_cell;
	float biodiversity_cell;
	list<float> dist_nat;
	list<nature> close_nat;
	list<cell> close_cell;
	list<people> my_people;

	
	action init_cell {
		add self to:close_cell;
		loop n over:neighbors {
		loop p over:n.neighbors {
			add p to:close_cell;
		}	
		add n to:close_cell;
		}
		close_cell<-remove_duplicates(close_cell);
		
		geometry ul<-union(close_cell);
		close_road<-road overlapping(ul);
		if length(water overlapping(ul))>0 {close_river<-true;}
		 road_density<-close_road sum_of(each.shape.perimeter/distance_impact_nat1);
		 building_density<-building overlapping(self)  sum_of(each.shape.area/4000#m2);
		 
		 do indic_computation;
		 
/* 	 ask nature {
	 	
	 	if (self distance_to(myself)<distance_impact_nat1) {
	 	add self to:myself.close_nature;
	 	cell ccn<-cell overlapping self closest_to(myself);
	 	add ccn distance_to(myself) to:myself.dist_nature;
	 		}
		 	} */
		 	}
	
	
	
	

	action reinitiate_cell_contibu {
	air_pollution_cell<-0.0;
	sound_pollution_cell<-0.0;
	water_pollution_cell<-0.0;
	soil_pollution_cell<-0.0;
	refresh_cell<-0.0;
	gentrification_cell<-0.0;
	urban_space_cell<-0.0;
	maintenance_cost_cell<-0.0;
	well_being_cell<-0.0;
	amenity_cell<-0.0;
	recreational_cell<-0.0;
	accessibility_cell<-0.0;
	production_cell<-0.0;
	sociability_cell<-0.0;
	autonomy_cell<-0.0;
	biomass_cell<-0.0;
	abundance_cell<-0.0;
	biodiversity_cell<-0.0;
	}
	
	
	
	action compute_nature_cell_contribu {

	do indic_computation;
	//air_pollution_cell<-pollution_lvl*(air_pollution_cell);
	sound_pollution_cell<-road_density*sound_pollution_cell;
	//water_pollution_cell<-building_density*water_pollution_cell;
	//soil_pollution_cell<-building_density*soil_pollution_cell;
	float modif_river<-0.0;
	if close_river {modif_river<-0.2;}
	refresh_cell<-max(0,min(1,(temperature-23)/10+warm_now/5-modif_river))*refresh_cell;

}

action indic_computation {
	float air_pol<-max(0,min(1,pollution_lvl-air_pollution_cell));
	float wat_pol<-max(0,min(1,building_density-soil_pollution_cell));
	float sou_pol<-max(0,min(1,road_density-sound_pollution_cell));
	float modif_river<-0.0;
	if close_river {modif_river<-0.2;}
	float warm_nv<-max(0,max(0,min(1,(temperature-23)/10+warm_now/5-modif_river))-refresh_cell);//-refresh_cell));
	

	quality_of_env<-1-(air_pol+wat_pol+sou_pol+warm_nv)/4;
		quality_env_color<-#limegreen;
	if quality_of_env<0.9 {quality_env_color<-#gamagreen;}
	if quality_of_env<0.8 {quality_env_color<-#olive;}
	if quality_of_env<0.7 {quality_env_color<-#darkkhaki;}
	if quality_of_env<0.6 {quality_env_color<-#burlywood;}
	if quality_of_env<0.5 {quality_env_color<-#darkgoldenrod;}
	if quality_of_env<0.4 {quality_env_color<-#peru;}
	if quality_of_env<0.3 {quality_env_color<-#gamaorange;}
	if quality_of_env<0.2 {quality_env_color<-#darkorange;}
	if quality_of_env<0.1 {quality_env_color<-#red;}
	
	//quality_env_color<-rgb(int(255 * (1-quality_of_env)), 255*(quality_of_env), 0);
	if length(my_people)<1 {satisfaction_color<-#black;}else {
	satisfaction<- my_people mean_of(each.satisfaction);	
	satisfaction_color<-#limegreen;
	if satisfaction<0.9 {satisfaction_color<-#gamagreen;}
	if satisfaction<0.8 {satisfaction_color<-#olive;}
	if satisfaction<0.7 {satisfaction_color<-#darkkhaki;}
	if satisfaction<0.6 {satisfaction_color<-#burlywood;}
	if satisfaction<0.5 {satisfaction_color<-#darkgoldenrod;}
	if satisfaction<0.4 {satisfaction_color<-#peru;}
	if satisfaction<0.3 {satisfaction_color<-#gamaorange;}
	if satisfaction<0.2 {satisfaction_color<-#darkorange;}
	if satisfaction<0.1 {satisfaction_color<-#red;}
	//satisfaction_color<-rgb(int(255 * (1-satisfaction)), 255*(satisfaction), 0);
	
	}
	
	
	
}


	
		aspect map{
				draw shape color:color;
	}
	
	
		aspect map_sat{
				draw shape color:satisfaction_color;
	}
	
		aspect map_quality{
				draw shape color:quality_env_color;
	}
	

	
}

experiment "Let's go" type: gui
{
	//parameter "File:" var: osmfile <- file<geometry> (osm_file("../includes/map.osm", filtering));
	
	parameter "Budget maintenance" var:budget<-3 min:0 max:5 ;
	

	
	output
	{
	
			display follow_env type:2d {
			graphics Strings {
			draw "date : "+string(current_date, "'Mois : 'MM' Année : 'yyyy") at: { 10#px,  20#px } color:#darkcyan font: font("Helvetica", 20, #bold);
			draw "temperature moyenne : "+temperature with_precision(2) at: { 10#px,  50#px } color:#darkcyan font: font("Helvetica", 20, #bold);
			draw "pluie totale : "+rain with_precision(2) at: { 10#px,  80#px } color:#darkcyan font: font("Helvetica", 20, #bold);
			draw "pollution : "+pollution_lvl with_precision(2) at: { 10#px,  110#px } color:#darkcyan font: font("Helvetica", 20, #bold);
		
		}
		}
		
		display carte type: 2d
		{
			species cell refresh: true aspect:map ;
			species nature refresh: true aspect:map_base; 
			species building refresh: false;
			species road;
			species water;
		//	species people;

			/* 	overlay position: { 5, 5 } size: { 800 #px, 180 #px } background: # black transparency: 0.4 border: #black rounded: true
            {   
             	draw "Nature technisiste" at: { 10#px,  40#px } color:#darkcyan font: font("Helvetica", 20, #bold);
            	draw "Allée d'arbres" at: { 10#px,  70#px } color:#blueviolet font: font("Helvetica", 20, #bold);
            	draw "Gestion traditionnelle " at: { 10#px,  100#px } color:#slategrey font: font("Helvetica", 20, #bold);
            	draw "Berge aménagée" at: { 10#px,  130#px } color:#dodgerblue font: font("Helvetica", 20, #bold);
            	draw "Agriculture urbaine" at: { 400#px,  40#px } color:#gold font: font("Helvetica", 20, #bold);
            	draw "Forêt urbaine" at: { 400#px,  70#px } color:#lime font: font("Helvetica", 20, #bold);
            	draw "Gestion différenciée" at: { 400#px,  100#px } color:#green font: font("Helvetica", 20, #bold);
            	draw "Ripisylve sauvage" at: { 400#px,  130#px } color:#darksalmon font: font("Helvetica", 20, #bold);
            	draw "Friche renaturée" at: { 10#px,  160#px } color:#firebrick font: font("Helvetica", 20, #bold);
            	
            	//0 : Nature technisiste ; 1: Allée d'arbres ; 2 : Gestion traditionnelle ; 3 : Berge aménagée
				// 4 : Agriculture urbaine ; 5 : Forêt urbaine, 6:Gestion différenciée
				// 7 : Ripisylve sauvage , 8 : Friche renaturée
		
            }*/
			
		}
		
		
				display quality_env type: 2d
		{
			species cell refresh: true aspect:map_quality ;
            species nature refresh: true aspect:nature_state transparency:0.1; 
            species road transparency:0.3;
            species building transparency:0.3;
            
            }
            
            				display carte_satisfaction type: 2d
		{
			species cell refresh: true aspect:map_sat ;
	     	species nature refresh: true aspect:nature_state transparency:0.7; 
          
		

            }
            
            

		
		display indicators type:2d {
				overlay position: { 5, 5 } size: { 400 #px, 30 #px } background: #grey transparency: 0.4 border: #black rounded: true
            {   
             	draw narrative_event at: { 10#px,  10#px } color:#black font: font("Helvetica", 10);
          
            	
		
            }
				chart "" type: series  x_serie_labels:(""+current_date.month+" - "+current_date.year){		
				data "Etat ZN" value:nature_state color: #green;
				data "Qualité Environnement" value:nature_quality color: #royalblue;
				data "Satisfaction" value:satisfaction color: #red;

				}
		}	
		
		

}
}
	



