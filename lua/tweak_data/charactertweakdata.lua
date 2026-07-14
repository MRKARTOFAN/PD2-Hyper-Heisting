local origin_presets = CharacterTweakData._presets
local origin_create_table_structure = CharacterTweakData._create_table_structure
local origin_charmap = CharacterTweakData.character_map

local function HHVec(strafe, fwd, bwd)
	return { strafe = strafe, fwd = fwd, bwd = bwd }
end

local function HHMoveSpeed(stand_ntl, stand_walk, stand_run, crouch_walk, crouch_run)
	return {
		stand = {
			walk = { ntl = stand_ntl, hos = stand_walk, cbt = stand_walk },
			run = { hos = stand_run, cbt = stand_run }
		},
		crouch = {
			walk = { hos = crouch_walk, cbt = crouch_walk },
			run = { hos = crouch_run, cbt = crouch_run }
		}
	}
end

local function HHRange(close, optimal, far, aggressive)
	local range = { close = close, optimal = optimal, far = far }
	if aggressive then
		range.aggressive = aggressive
	end
	return range
end

local function HHFalloff(dmg_mul, r, acc_min, acc_max, recoil_min, recoil_max, mode_1, mode_2, mode_3, mode_4, autofire_rounds)
	local data = {
		dmg_mul = dmg_mul,
		r = r,
		acc = { acc_min, acc_max },
		recoil = { recoil_min, recoil_max },
		mode = { mode_1, mode_2, mode_3, mode_4 }
	}

	if autofire_rounds then
		data.autofire_rounds = autofire_rounds
	end

	return data
end


local function HHHectorBossShotgunFalloff(high_damage)
	if high_damage then
		return {
			HHFalloff(3.14, 200, 0.6, 0.9, 0.4, 0.7, 0, 1, 2, 1),
			HHFalloff(2.5, 500, 0.6, 0.9, 0.4, 0.7, 0, 3, 3, 1),
			HHFalloff(2.1, 1000, 0.4, 0.8, 0.45, 0.8, 1, 2, 2, 0),
			HHFalloff(1.8, 2000, 0.4, 0.55, 0.45, 0.8, 3, 2, 2, 0),
			HHFalloff(1.4, 3000, 0.1, 0.35, 1, 1.2, 3, 1, 1, 0)
		}
	end

	return {
		HHFalloff(2.2, 200, 0.6, 0.9, 0.4, 0.7, 0, 1, 2, 1),
		HHFalloff(1.75, 500, 0.6, 0.9, 0.4, 0.7, 0, 3, 3, 1),
		HHFalloff(1.5, 1000, 0.4, 0.8, 0.45, 0.8, 1, 2, 2, 0),
		HHFalloff(1.25, 2000, 0.4, 0.55, 0.45, 0.8, 3, 2, 2, 0),
		HHFalloff(1, 3000, 0.1, 0.35, 1, 1.2, 3, 1, 1, 0)
	}
end

local function FRAYSetHectorBossShotgunFalloff(self, high_damage)
	self.hector_boss.weapon.is_shotgun_mag.FALLOFF = HHHectorBossShotgunFalloff(high_damage)
end

local function FRAYSetBossHealth(self, health)
	for _, name in ipairs({ "hector_boss", "mobster_boss", "biker_boss", "chavez_boss" }) do
		self[name].HEALTH_INIT = health
	end
end


local function FRAYSetPhalanx(self, minion_health, minion_clamp, vip_health, vip_clamp)
	self.phalanx_minion.HEALTH_INIT = minion_health
	self.phalanx_minion.DAMAGE_CLAMP_BULLET = minion_clamp
	self.phalanx_minion.DAMAGE_CLAMP_EXPLOSION = minion_clamp
	self.phalanx_vip.HEALTH_INIT = vip_health
	self.phalanx_vip.DAMAGE_CLAMP_BULLET = vip_clamp
	self.phalanx_vip.DAMAGE_CLAMP_EXPLOSION = vip_clamp
end

local function FRAYSetGangMemberDamage(self)
	local damage = self.presets.gang_member_damage
	damage.REGENERATE_TIME = 7.5
	damage.REGENERATE_TIME_AWAY = 7.5
	damage.HEALTH_INIT = 500
	damage.MIN_DAMAGE_INTERVAL = 0.35
end

local function FRAYSetSpoocAttackTimeout(self)
	self.shadow_spooc.shadow_spooc_attack_timeout = { 0.35, 0.35 }
	self.spooc.spooc_attack_timeout = { 0.35, 0.35 }
end

local function FRAYSetMinObjInterruptDistances(self)
	if self.taser then
		self.taser.min_obj_interrupt_dis = 1000
	end

	for _, name in ipairs({ "spooc", "shadow_spooc", "spooc_heavy" }) do
		if self[name] then
			self[name].min_obj_interrupt_dis = 800
		end
	end

	for _, name in ipairs({ "tank", "tank_hw", "tank_medic", "tank_mini", "tank_ftsu", "trolliam_epicson", "shield" }) do
		if self[name] then
			self[name].min_obj_interrupt_dis = 600
		end
	end
end

function CharacterTweakData:_init_region_shared()
	self:_init_region_america()
end

--LANDMARK: SHARK

--TODO: Lots of untested stuff right now, get testing it solo, if it works, it works, if it doesn't, make it work.

function CharacterTweakData:_presets(tweak_data)
	local presets = origin_presets(self, tweak_data)

	--replace existing suppression presets with lighter and consistent ones to accomodate for lack of immediate enemy suppression
	presets.suppression = {
		easy = {
			panic_chance_mul = 1,
			duration = {
				5,
				10
			},
			react_point = {
				2,
				2
			},
			brown_point = {
				6,
				6
			}
		},
		hard_def = {
			panic_chance_mul = 0.7,
			duration = {
				5,
				10
			},
			react_point = {
				6,
				6
			},
			brown_point = {
				12,
				12
			}
		},
		hard_agg = {
			panic_chance_mul = 0.7,
			duration = {
				2.5,
				5
			},
			react_point = {
				12,
				12
			},
			brown_point = {
				24,
				24
			}
		},
		no_supress = {
			panic_chance_mul = 0,
			duration = {
				0.1,
				0.15
			},
			react_point = {
				100,
				200
			},
			brown_point = {
				400,
				500
			}
		}
	}
	presets.surrender = {
		always = {
			base_chance = 1
		},
		never = {
			base_chance = 0
		},
		easy = {
			base_chance = 0,
			reasons = {
				pants_down = 1,
				isolated = 0.25,
				weapon_down = 0.25,
				health = {
					[1.0] = 0,
					[0.8] = 0.75
				}
			},
			factors = {
				unaware_of_aggressor = 0.075,
				enemy_weap_cold = 0.5,
				flanked = 0.5,
				aggressor_dis = {
					[300.0] = 0.2,
					[1000.0] = 0
				}
			}
		},
		normal = {
			base_chance = 0,
			significant_chance = 0.1,
			reasons = {
				pants_down = 1,
				isolated = 0.25,
				weapon_down = 0.25,
				health = {
					[1.0] = 0,
					[0.6] = 0.75
				}
			},
			factors = {
				unaware_of_aggressor = 0.075,
				enemy_weap_cold = 0.5,
				flanked = 0.5,
				aggressor_dis = {
					[300.0] = 0.2,
					[1000.0] = 0
				}
			}
		},
		hard = {
			base_chance = 0.1,
			significant_chance = 0.6,
			reasons = {
				pants_down = 1,
				isolated = 0.25,
				weapon_down = 0.25,
				health = {
					[1.0] = 0,
					[0.8] = 0.5
				}
			},
			factors = {
				unaware_of_aggressor = 0.075,
				enemy_weap_cold = 0.5,
				flanked = 0.5,
				aggressor_dis = {
					[300.0] = 0.2,
					[1000.0] = 0
				}
			}
		},
		special = {
			base_chance = 0, --0% base chance of surrender, quite literally.
			significant_chance = 0.75, --due to the math used, you have to subtract this amount from 1 to figure out the minimum chance for them to even try to surrender, in this case, its 0.25, aka, 25%, you need at least 25%
			reasons = {
				pants_down = 0, --an enemy that went uncool and was previously cool will get THIS much percentage, in this case, 0%
				weapon_down = 0.1, --hurt or animations in which they cant shoot add 10%
				health = {
					[1] = 0,
					[0.5] = 0.35 --if the enemy is at less than 50% health, they gain 35% surrender chance
				}
			},
			factors = {
				enemy_weap_cold = 0.1, --if an assault is not active, they gain 10% surrender chance
				unaware_of_aggressor = 0,
				aggressor_dis = {
					[300.0] = 0.1, --if the aggressor/intimidator is within 3 meters of distance, they gain 10% surrender chance
					[400.0] = 0
				}
			}
			--overall surrender chance: 45% or 0.45 assuming an assault is active, and no skills boosting the chance
		}
	}

	--Custom suppression presets for certain types of enemies which should be affected by suppressive effects but not have damage reactions, flawed, yes, but it's the best that can currently be done until someone can help me figure out how to disable the suppression resistance and instantaneous build up on hit.
	presets.suppression.stalwart_nil = {
        panic_chance_mul = 0,
        duration = {
            2,
            2
        },
        brown_point = {
            400,
            500
        }
    }
	presets.suppression.stalwart_agg = {
        panic_chance_mul = 0.7,
        duration = {
            5,
            8
        },
        brown_point = {
            5,
            6
        }
    }
	presets.suppression.stalwart_def = {
        panic_chance_mul = 0.7,
        duration = {
            5,
            10
        },
        brown_point = {
            5,
            6
        }
    }
	presets.suppression.stalwart_easy = {
        panic_chance_mul = 1,
        duration = {
            10,
            15
        },
        brown_point = {
            3,
            5
        }
    }

	--Dodge presets begin here.
	presets.dodge = {
		poor = {
			speed = 0.8,
			occasions = {
				scared = {
					chance = 0.5,
					check_timeout = {
						1,
						2
					},
					variations = {
						side_step = {
							chance = 1,
							timeout = {
								2,
								3
							}
						}
					}
				}
			}
		},
		average = {
			speed = 1,
			occasions = {
				scared = {
					chance = 0.4,
					check_timeout = {
						0.8,
						0.8
					},
					variations = {
						side_step = {
							chance = 1,
							timeout = {
								1,
								2
							}
						}
					}
				},
				hit = {
					chance = 0.5,
					check_timeout = {
						0.6,
						0.6
					},
					variations = {
						side_step = {
							chance = 1,
							timeout = {
								2,
								3
							}
						}
					}
				}
			}
		},
		heavy = {
			speed = 1,
			occasions = {
				hit = {
					chance = 0.75,
					check_timeout = {
						0.8,
						0.8
					},
					variations = {
						side_step = {
							chance = 7,
							shoot_chance = 0.8,
							shoot_accuracy = 0.5,
							timeout = {
								0,
								7
							}
						},
						roll = {
							chance = 3,
							timeout = {
								8,
								10
							}
						}
					}
				},
				preemptive = {
					chance = 0.6,
					check_timeout = {
						1,
						4
					},
					variations = {
						side_step = {
							chance = 1,
							shoot_chance = 1,
							shoot_accuracy = 0.7,
							timeout = {
								1,
								7
							}
						}
					}
				},
				scared = {
					chance = 0.6,
					check_timeout = {
						1,
						2
					},
					variations = {
						side_step = {
							chance = 5,
							shoot_chance = 0.5,
							shoot_accuracy = 0.4,
							timeout = {
								1,
								2
							}
						},
						dive = {
							chance = 1,
							timeout = {
								8,
								10
							}
						}
					}
				}
			}
		},
		athletic = {
			speed = 1.2,
			occasions = {
				hit = {
					chance = 0.9,
					check_timeout = {
						0.5,
						0.5
					},
					variations = {
						side_step = {
							chance = 5,
							shoot_chance = 0.8,
							shoot_accuracy = 0.5,
							timeout = {
								1,
								3
							}
						},
						roll = {
							chance = 1,
							timeout = {
								3,
								4
							}
						}
					}
				},
				preemptive = {
					chance = 0.75,
					check_timeout = {
						0.6,
						0.6
					},
					variations = {
						side_step = {
							chance = 3,
							shoot_chance = 1,
							shoot_accuracy = 0.7,
							timeout = {
								1,
								2
							}
						},
						roll = {
							chance = 1,
							timeout = {
								3,
								4
							}
						}
					}
				},
				scared = {
					chance = 0.6,
					check_timeout = {
						0.8,
						0.8
					},
					variations = {
						side_step = {
							chance = 6,
							shoot_chance = 0.5,
							shoot_accuracy = 0.4,
							timeout = {
								1,
								2
							}
						},
						dive = {
							chance = 4,
							timeout = {
								3,
								5
							}
						}
					}
				}
			}
		},
		ninja = {
			speed = 1.3,
			occasions = {
				hit = {
					chance = 1,
					check_timeout = {
						0.6,
						0.6
					},
					variations = {
						side_step = {
							chance = 3,
							shoot_chance = 1,
							shoot_accuracy = 0.7,
							timeout = {
								1,
								2
							}
						},
						roll = {
							chance = 1,
							timeout = {
								1.2,
								2
							}
						},
						wheel = {
							chance = 2,
							timeout = {
								1.2,
								2
							}
						}
					}
				},
				preemptive = {
					chance = 1,
					check_timeout = {
						0.6,
						0.6
					},
					variations = {
						side_step = {
							chance = 3,
							shoot_chance = 1,
							shoot_accuracy = 0.8,
							timeout = {
								1,
								2
							}
						},
						roll = {
							chance = 1,
							timeout = {
								1.2,
								2
							}
						},
						wheel = {
							chance = 2,
							timeout = {
								1.2,
								2
							}
						}
					}
				},
				scared = {
					chance = 0.9,
					check_timeout = {
						0.8,
					    0.8
					},
					variations = {
						side_step = {
							chance = 0.33,
							shoot_chance = 0.8,
							shoot_accuracy = 0.6,
							timeout = {
								1,
								2
							}
						},
						roll = {
							chance = 0.34,
							timeout = {
								1.2,
								2
							}
						},
						wheel = {
							chance = 0.33,
							timeout = {
								1.2,
								2
							}
						}
					}
				}
			}
		}
	}

	presets.dodge.heavy_complex = {
		speed = 1.2,
		occasions = {
			hit = {
				chance = 1,
				check_timeout = {
					0,
					0
				},
				variations = {
					side_step = {
						chance = 0.5,
						shoot_chance = 1,
						shoot_accuracy = 1,
						timeout = {
							1,
							2
						}
					},
					dive = {
						chance = 0.25,
						timeout = {
							1,
							2
						}
					},
					roll = {
						chance = 0.25,
						timeout = {
							1,
							2
						}
					}
				}
			},
			preemptive = {
				chance = 1,
				check_timeout = {
					2,
					3
				},
				variations = {
					roll = {
						chance = 0.5,
						timeout = {
							0.7,
							1
						}
					},
					side_step = {
						chance = 0.5,
						shoot_chance = 1,
						shoot_accuracy = 0.9,
						timeout = {
							0.75,
							1
						}
					}
				}
			},
			scared = {
				chance = 1,
				check_timeout = {
					0,
					0
				},
				variations = {
					dive = {
						chance = 0.5,
						timeout = {
							2,
							2
						}
					},
					roll = {
						chance = 0.5,
						timeout = {
							1,
							2
						}
					}
				}
			}
		}
	}
	presets.dodge.athletic_complex = {
		speed = 1.4,
		occasions = {
			hit = {
				chance = 1,
				check_timeout = {
					0,
					0
				},
				variations = {
					side_step = {
						chance = 0.5,
						shoot_chance = 1,
						shoot_accuracy = 1,
						timeout = {
							0.5,
							0.5
						}
					},
					roll = {
						chance = 0.5,
						timeout = {
							0.5,
							0.5
						}
					}
				}
			},
			preemptive = {
				chance = 1,
				check_timeout = {
					1,
					2
				},
				variations = {
					side_step = {
						chance = 1,
						shoot_chance = 1,
						shoot_accuracy = 1,
						timeout = {
							0.5,
							0.5
						}
					}
				}
			},
			scared = {
				chance = 1,
				check_timeout = {
					0,
					0
				},
				variations = {
					side_step = {
						chance = 0.4,
						shoot_chance = 1,
						shoot_accuracy = 0.6,
						timeout = {
							0.5,
							0.5
						}
					},
					roll = {
						chance = 0.6,
						timeout = {
							0.5,
							0.5
						}
					}
				}
			}
		}
	}
	presets.dodge.ninja_complex = {
			speed = 1.6,
			occasions = {
				hit = {
					chance = 1,
					check_timeout = {
						0,
						0
					},
					variations = {
						roll = {
							chance = 0.5,
							shoot_chance = 1,
							shoot_accuracy = 1,
							timeout = {
								0.5,
								0.5
							}
						},
						wheel = {
							chance = 0.5,
							shoot_chance = 1,
							shoot_accuracy = 1,
							timeout = {
								0.35,
								0.35
							}
						}
					}
				},
				preemptive = {
					chance = 1,
					check_timeout = {
						0,
						0
					},
					variations = {
						side_step = {
							chance = 0.33,
							shoot_chance = 1,
							shoot_accuracy = 1,
							timeout = {
								0.5,
								0.5
							}
						},
						roll = {
							chance = 0.33,
							shoot_chance = 1,
							shoot_accuracy = 1,
							timeout = {
								0.5,
								0.5
							}
						},
						wheel = {
							chance = 0.34,
							shoot_chance = 1,
							shoot_accuracy = 1,
							timeout = {
								0.35,
								0.35
							}
						}
					}
				},
				scared = {
					chance = 1,
					check_timeout = {
						0,
						0
					},
					variations = {
						wheel = {
							chance = 1,
							shoot_chance = 1,
							shoot_accuracy = 1,
							timeout = {
								0.35,
								0.35
							}
						}
					}
				}
			}
		}

	for preset_name, preset_data in pairs(presets.dodge) do
		for reason_name, reason_data in pairs(preset_data.occasions) do
			local total_w = 0

			for variation_name, variation_data in pairs(reason_data.variations) do
				total_w = total_w + variation_data.chance
			end

			if total_w > 0 then
				for variation_name, variation_data in pairs(reason_data.variations) do
					variation_data.chance = variation_data.chance / total_w
				end
			end
		end
	end

	--Custom move speeds start here to keep enemy approaches and movement consistent.
	presets.move_speed.simple_consistency = HHMoveSpeed(HHVec(120, 150, 100), HHVec(285, 285, 285), HHVec(670, 670, 670), HHVec(255, 255, 255), HHVec(357, 357, 357))
	--1.1x mul
	presets.move_speed.civil_consistency = HHMoveSpeed(HHVec(120, 150, 100), HHVec(313, 313, 313), HHVec(737, 737, 737), HHVec(280, 280, 280), HHVec(393, 393, 393))
	--1.15x mul
	presets.move_speed.complex_consistency = HHMoveSpeed(HHVec(120, 150, 100), HHVec(327, 327, 327), HHVec(770, 770, 770), HHVec(293, 293, 293), HHVec(410, 410, 410))
	--1.2x mul
	presets.move_speed.anarchy_consistency = HHMoveSpeed(HHVec(120, 150, 100), HHVec(342, 342, 342), HHVec(804, 804, 804), HHVec(306, 306, 306), HHVec(428, 428, 428))

	--preset for dozers
	presets.move_speed.slow_consistency = HHMoveSpeed(HHVec(60, 80, 50), HHVec(144, 144, 144), HHVec(360, 360, 360), HHVec(144, 144, 144), HHVec(360, 360, 360))
	--minigun dozer movespeed
	presets.move_speed.mini_consistency = HHMoveSpeed(HHVec(144, 144, 144), HHVec(144, 144, 144), HHVec(144, 144, 144), HHVec(144, 144, 144), HHVec(144, 144, 144))
	--preset for cloakers to keep them zippy and fast no matter what
	presets.move_speed.lightning_constant = HHMoveSpeed(HHVec(240, 300, 200), HHVec(800, 800, 800), HHVec(800, 800, 800), HHVec(800, 800, 800), HHVec(800, 800, 800))

	presets.move_speed.speedofsoundsonic = HHMoveSpeed(HHVec(240, 300, 200), HHVec(1000, 1000, 1000), HHVec(1000, 1000, 1000), HHVec(1000, 1000, 1000), HHVec(1000, 1000, 1000))

	presets.move_speed.teamai = HHMoveSpeed(HHVec(120, 150, 100), HHVec(350, 350, 350), HHVec(862.50, 862.50, 862.50), HHVec(225, 225, 225), HHVec(272, 272, 272))

	--making base-game presets clone my new set of movespeed presets
	presets.move_speed.slow = deep_clone(presets.move_speed.slow_consistency)
	presets.move_speed.very_slow = deep_clone(presets.move_speed.mini_consistency)
	presets.move_speed.normal = deep_clone(presets.move_speed.simple_consistency)
	presets.move_speed.fast = deep_clone(presets.move_speed.simple_consistency)
	presets.move_speed.very_fast = deep_clone(presets.move_speed.civil_consistency)

	--prevents Application has crashed: C++ exception[string "core/lib/utils/coretable.lua"]:32: bad argument #1 to 'pairs' (table expected, got nil)
	for speed_preset_name, poses in pairs(presets.move_speed) do
		for pose, hastes in pairs(poses) do
			hastes.run.ntl = hastes.run.hos
		end
		poses.crouch.walk.ntl = poses.crouch.walk.hos
		poses.crouch.run.ntl = poses.crouch.run.hos
		poses.stand.run.ntl = poses.stand.run.hos
		poses.panic = poses.stand
	end

	--detection preset for regular enemies so they are fully capable of identifying players during loud
	presets.detection.enemymook = {
		idle = {},
		combat = {},
		recon = {},
		guard = {},
		ntl = {}
	}
	presets.detection.enemymook.idle.dis_max = 10000
	presets.detection.enemymook.idle.angle_max = 110
	presets.detection.enemymook.idle.delay = { 0, 0 }
	presets.detection.enemymook.idle.use_uncover_range = true
	presets.detection.enemymook.combat.dis_max = 10000
	presets.detection.enemymook.combat.angle_max = 110
	presets.detection.enemymook.combat.delay = { 0, 0 }
	presets.detection.enemymook.combat.use_uncover_range = true
	presets.detection.enemymook.recon.dis_max = 10000
	presets.detection.enemymook.recon.angle_max = 110
	presets.detection.enemymook.recon.delay = { 0, 0 }
	presets.detection.enemymook.recon.use_uncover_range = true
	presets.detection.enemymook.guard.dis_max = 10000
	presets.detection.enemymook.guard.angle_max = 110
	presets.detection.enemymook.guard.delay = { 0, 0 }
	presets.detection.enemymook.ntl.use_uncover_range = nil
	presets.detection.enemymook.ntl.dis_max = 1500
	presets.detection.enemymook.ntl.angle_max = 60
	presets.detection.enemymook.ntl.delay = { 0.5, 2 }
	presets.detection.civilian.cbt.dis_max = 700
	presets.detection.civilian.cbt.angle_max = 120
	presets.detection.civilian.cbt.delay = { 0, 0 }
	presets.detection.civilian.cbt.use_uncover_range = true
	presets.detection.civilian.ntl.use_uncover_range = nil
	presets.detection.civilian.ntl.dis_max = 2000
	presets.detection.civilian.ntl.angle_max = 60
	presets.detection.civilian.ntl.delay = { 0.2, 3 }

	presets.detection.enemyspooc = {
		idle = {},
		combat = {},
		recon = {},
		guard = {},
		ntl = {}
	}
	presets.detection.enemyspooc.idle.dis_max = 10000
	presets.detection.enemyspooc.idle.angle_max = 110
	presets.detection.enemyspooc.idle.delay = { 0, 0 }
	presets.detection.enemyspooc.idle.use_uncover_range = true
	presets.detection.enemyspooc.combat.dis_max = 10000
	presets.detection.enemyspooc.combat.angle_max = 110
	presets.detection.enemyspooc.combat.delay = { 0, 0 }
	presets.detection.enemyspooc.combat.use_uncover_range = true
	presets.detection.enemyspooc.recon.dis_max = 10000
	presets.detection.enemyspooc.recon.angle_max = 110
	presets.detection.enemyspooc.recon.delay = { 0, 0 }
	presets.detection.enemyspooc.recon.use_uncover_range = true
	presets.detection.enemyspooc.guard.dis_max = 10000
	presets.detection.enemyspooc.guard.angle_max = 110
	presets.detection.enemyspooc.guard.delay = { 0, 0 }
	presets.detection.enemyspooc.ntl.use_uncover_range = nil
	presets.detection.enemyspooc.ntl.dis_max = 3000
	presets.detection.enemyspooc.ntl.angle_max = 80
	presets.detection.enemyspooc.ntl.delay = { 0.5, 2 }
	presets.detection.gang_member = {
		idle = {},
		combat = {},
		recon = {},
		guard = {},
		ntl = {}
	}
	presets.detection.gang_member.idle.dis_max = 20000
	presets.detection.gang_member.idle.angle_max = 360
	presets.detection.gang_member.idle.delay = { 0, 0 }
	presets.detection.gang_member.idle.use_uncover_range = true
	presets.detection.gang_member.combat.dis_max = 20000
	presets.detection.gang_member.combat.angle_max = 360
	presets.detection.gang_member.combat.delay = { 0, 0 }
	presets.detection.gang_member.combat.use_uncover_range = true
	presets.detection.gang_member.recon.dis_max = 20000
	presets.detection.gang_member.recon.angle_max = 360
	presets.detection.gang_member.recon.delay = { 0, 0 }
	presets.detection.gang_member.recon.use_uncover_range = true
	presets.detection.gang_member.guard.dis_max = 20000
	presets.detection.gang_member.guard.angle_max = 360
	presets.detection.gang_member.guard.delay = { 0, 0 }
	presets.detection.gang_member.ntl.use_uncover_range = true
	presets.detection.gang_member.ntl.dis_max = 1500
	presets.detection.gang_member.ntl.angle_max = 360
	presets.detection.gang_member.ntl.delay = { 0, 0 }


	--make normal clone my new preset to keep enemies not currently set here capable of detecting people too
	presets.detection.normal = deep_clone(presets.detection.enemymook)
	presets.detection.guard = deep_clone(presets.detection.enemymook)

	--custom hurt severities start here, focus on less enemy down time as enemy health goes up
	--satisfying staggering behavior, burying full auto rounds into enemies faces eventually makes them fall over and squirm, anything that deals immediate large damage staggers enemies consistently.
	--melee becomes gratifying, rewarding and ridiculously fun using explodes
	presets.hurt_severities.hordemook = {
		doom_light = true,
		bullet = {
			health_reference = "current",
			zones = {
				{
					heavy = 0.05,
					health_limit = 0.1,
					light = 0.8,
					moderate = 0.15,
				},
				{
					heavy = 0.1,
					light = 0.7,
					moderate = 0.15,
					health_limit = 0.15
				},
				{
					heavy = 0.2,
					light = 0.6,
					moderate = 0.2,
					health_limit = 0.2
				},
				{
					heavy = 0.6,
					light = 0,
					moderate = 0.4,
					health_limit = 0.25
				},
				{
					heavy = 0.4,
					explode = 0.4,
					moderate = 0.2,
					health_limit = 0.35
				},
				{
					explode = 0.33,
					moderate = 0.33,
					heavy = 0.33
				}
			}
		},
		explosion = {
			health_reference = "current",
			zones = {
				{
					moderate = 0.6,
					heavy = 0.4,
					health_limit = 0.2
				},
				{
					explode = 0.4,
					heavy = 0.6,
					health_limit = 0.5
				},
				{
					explode = 0.8,
					heavy = 0.2
				}
			}
		},
		melee = {
			health_reference = "current",
			zones = {
				{
					heavy = 0,
					health_limit = 0.05,
					light = 0.7,
					moderate = 0.3,
					none = 0
				},
				{
					heavy = 0.4,
					light = 0,
					explode = 0,
					moderate = 0.6,
					health_limit = 0.2
				},
				{
					heavy = 0.2,
					explode = 0.4,
					moderate = 0.4,
					health_limit = 0.3
				},
				{
					explode = 0.8,
					heavy = 0.2
				}
			}
		},
		fire = {
			health_reference = "current",
			zones = {
				{
					fire = 1
				}
			}
		},
		poison = {
			health_reference = "current",
			zones = {
				{
					poison = 1,
					none = 0
				}
			}
		}
	}

	presets.hurt_severities.hordepunk = {
		bullet = {
			health_reference = 1,
			zones = {
				{
					heavy = 0.2,
					moderate = 0.8
				}
			}
		},
		explosion = {
			health_reference = "current",
			zones = {
				{
					moderate = 0.6,
					heavy = 0.4,
					health_limit = 0.2
				},
				{
					explode = 0.4,
					heavy = 0.6,
					health_limit = 0.5
				},
				{
					explode = 0.8,
					heavy = 0.2
				}
			}
		},
		melee = {
			health_reference = "current",
			zones = {
				{
					heavy = 0.3,
					health_limit = 0.05,
					moderate = 0.7,
					none = 0
				},
				{
					heavy = 0.4,
					light = 0,
					explode = 0,
					moderate = 0.6,
					health_limit = 0.2
				},
				{
					heavy = 0.2,
					explode = 0.4,
					moderate = 0.4,
					health_limit = 0.3
				},
				{
					explode = 0.8,
					heavy = 0.2
				}
			}
		},
		fire = {
			health_reference = "current",
			zones = {
				{
					fire = 1
				}
			}
		},
		poison = {
			health_reference = "current",
			zones = {
				{
					poison = 1,
					none = 0
				}
			}
		}
	}

	presets.hurt_severities.heavyhordemook = {
		bullet = {
			health_reference = "current",
			zones = {
				{
					heavy = 0.05,
					health_limit = 0.2,
					light = 0.9,
					moderate = 0.05,
				},
				{
					heavy = 0.3,
					light = 0.3,
					moderate = 0.4,
					health_limit = 0.3
				},
				{
					heavy = 0.4,
					light = 0.2,
					moderate = 0.4,
					health_limit = 0.4
				},
				{
					heavy = 0.5,
					light = 0,
					moderate = 0.5,
					health_limit = 0.5
				},
				{
					heavy = 0.4,
					explode = 0.2,
					moderate = 0.4,
					health_limit = 0.6
				},
				{
					moderate = 9
				}
			}
		},
		explosion = {
			health_reference = "current",
			zones = {
				{
					moderate = 0.6,
					heavy = 0.4,
					health_limit = 0.2
				},
				{
					explode = 0.4,
					heavy = 0.6,
					health_limit = 0.5
				},
				{
					explode = 0.5,
					heavy = 0.5
				}
			}
		},
		melee = {
			health_reference = "current",
			zones = {
				{
					heavy = 0,
					health_limit = 0.1,
					light = 0.7,
					moderate = 0.3,
					none = 0
				},
				{
					heavy = 0.4,
					light = 0,
					explode = 0,
					moderate = 0.6,
					health_limit = 0.3
				},
				{
					heavy = 0.2,
					explode = 0.4,
					moderate = 0.4,
					health_limit = 0.4
				},
				{
					moderate = 0.5,
					heavy = 0.5
				}
			}
		},
		fire = {
			health_reference = "current",
			zones = {
				{
					fire = 0.05,
					none = 0.95
				}
			}
		},
		poison = {
			health_reference = "current",
			zones = {
				{
					poison = 0.25,
					none = 0.75,
					--none = 0
				}
			}
		}
	}

	presets.hurt_severities.specialenemy = {
		bullet = {
			health_reference = "current",
			zones = {
				{
					heavy = 0,
					health_limit = 0.3, --increase health limits for minimum staggers, needs significant damage before they start reacting
					light = 0.95,
					moderate = 0.05,
				},
				{
					heavy = 0.05,
					light = 0.9,
					moderate = 0.05,
					health_limit = 0.4
				},
				{
					heavy = 0.2,
					light = 0.6,
					moderate = 0.2,
					health_limit = 0.5
				},
				{
					moderate = 1
				}
			}
		},
		explosion = {
			health_reference = "current",
			zones = {
				{
					moderate = 0.6, --no explode reacts
					heavy = 0.4,
					health_limit = 0.5
				},
				{
					explode = 0.5,
					heavy = 0.5
				}
			}
		},
		melee = {
			health_reference = "current",
			zones = {
				{
					heavy = 0,
					health_limit = 0.2,
					light = 0.7,
					moderate = 0.3,
					none = 0
				},
				{
					heavy = 0.4,
					light = 0,
					explode = 0,
					moderate = 0.6,
					health_limit = 0.45
				},
				{
					heavy = 0.2,
					explode = 0.4,
					moderate = 0.4,
					health_limit = 0.6
				},
				{
					light = 0,
					heavy = 0.8,
					explode = 0.2
				}
			}
		},
		fire = {
			health_reference = "current",
			zones = {
				{
					fire = 0.025,
					none = 0.975,
				}
			}
		},
		poison = {
			health_reference = "current",
			zones = {
				{
					poison = 0.05,
					none = 0.95
				}
			}
		}
	}

	presets.hurt_severities.no_hurts = { --due to overkill's recent updates, i have to do this now, apparently >:c
		tase = true,
		bullet = {
			health_reference = 1,
			zones = {
				{
					none = 1
				}
			}
		},
		explosion = {
			health_reference = 1,
			zones = {
				{
					none = 1
				}
			}
		},
		melee = {
			health_reference = 1,
			zones = {
				{
					none = 1
				}
			}
		},
		fire = {
			health_reference = 1,
			zones = {
				{
					none = 1
				}
			}
		},
		poison = {
			health_reference = 1,
			zones = {
				{
					none = 1
				}
			}
		}
	}
	presets.hurt_severities.no_hurts_no_tase = deep_clone(presets.hurt_severities.no_hurts)
	presets.hurt_severities.no_hurts_no_tase.tase = false

	--special no_tase hurt severities based on specialenemy, possibly used on taser.
	presets.hurt_severities.no_tase_special = deep_clone(presets.hurt_severities.specialenemy)
	presets.hurt_severities.no_tase_special.tase = false

	--no more weirdness with gangsters
	presets.hurt_severities.base = deep_clone(presets.hurt_severities.hordemook)

	presets.base.damage.tased_response = {
		light = {
			down_time = nil,
			tased_time = 1
		},
		heavy = {
			down_time = nil,
			tased_time = 5
		}
	}

	--Custom sniper preset to make them work differently, they work as a mini turret of sorts, dealing big damage with good accuracy, standing in their line of fire isn't wise as they'll suppress the shit out of you and take off armor very quickly.
	presets.weapon.rhythmsniper = deep_clone(presets.weapon.sniper)
	presets.weapon.rhythmsniper.is_rifle.autofire_rounds = nil
	presets.weapon.rhythmsniper.is_rifle.focus_delay = 0.8
	presets.weapon.rhythmsniper.is_rifle.fireline_t = 3 --how long it takes for enemies to reset their focus and aim delay.
	presets.weapon.rhythmsniper.is_rifle.tracking_speed = 400
	presets.weapon.rhythmsniper.is_rifle.aim_delay = { 0, 0 }
	presets.weapon.rhythmsniper.is_rifle.FALLOFF = { HHFalloff(5, 10000, 0, 1, 0.8, 0.8, 0, 0, 0, 1), HHFalloff(5, 20000, 0, 0.5, 0.8, 0.8, 0, 0, 0, 1) }

	--Weapon presets setup starts here, simple corresponds to swat, civil to fbi, complex to gensec and anarchy to zeal.

	--TODO: A lot of these comments are completely outdated and from older designs based on Vanilla Version, I should clean this up later for better understanding.

	--Differences between difficulties are a mix of spawngroup changes, custom units escalating gameplay complexity (when I get to that) and enemy numbers escalating to 80.
	presets.weapon.simple = deep_clone(presets.weapon.normal)
	presets.weapon.civil = deep_clone(presets.weapon.normal)
	presets.weapon.complex = deep_clone(presets.weapon.normal)
	presets.weapon.anarchy = deep_clone(presets.weapon.normal)

	--Simple preset begins here, lets players settle in.

	presets.weapon.simple.is_pistol = {
		aim_delay = { --no aim delay
			0,
			0
		},
		focus_delay = 2, --halved focus delay, still a lot, but pistols have good accuracy, so it's fair
		focus_dis = 500,
		spread = 25,
		miss_dis = 30,
		RELOAD_SPEED = 0.6, --cops will reload their weapons slower, and realistically, no tweaks from simple to this one
		melee_speed = 1.5,
		melee_dmg = 5,
		melee_retry_delay = {
			1,
			1
		},
		range = HHRange(2000, 3000, 4000),
		FALLOFF = { HHFalloff(3, 100, 0.1, 0.9, 0.4, 0.45, 1, 0, 0, 0), HHFalloff(3, 500, 0.1, 0.85, 0.45, 0.45, 1, 0, 0, 0), HHFalloff(2, 1000, 0, 0.55, 0.5, 0.6, 1, 0, 0, 0), HHFalloff(1, 2000, 0, 0.45, 0.55, 0.6, 1, 0, 0, 0), HHFalloff(1, 3000, 0, 0.2, 0.9, 1, 1, 0, 0, 0), HHFalloff(0.1, 4000, 0, 0.01, 0.9, 1.2, 1, 0, 0, 0) }
	}
	presets.weapon.simple.akimbo_pistol = { --fuck this shit, akimbos are now cosmetic
		aim_delay = { --no aim delay
			0,
			0
		},
		focus_delay = 2, --halved focus delay, still a lot, but pistols have good accuracy, so it's fair
		focus_dis = 500,
		spread = 25,
		miss_dis = 30,
		RELOAD_SPEED = 0.6, --cops will reload their weapons slower, and realistically, no tweaks from simple to this one
		melee_speed = 1.5,
		melee_dmg = 5,
		melee_retry_delay = {
			1,
			1
		},
		range = HHRange(2000, 3000, 4000),
		FALLOFF = { HHFalloff(3, 100, 0.1, 0.9, 0.4, 0.45, 1, 0, 0, 0), HHFalloff(3, 500, 0.1, 0.85, 0.45, 0.45, 1, 0, 0, 0), HHFalloff(2, 1000, 0, 0.55, 0.5, 0.6, 1, 0, 0, 0), HHFalloff(1, 2000, 0, 0.45, 0.55, 0.6, 1, 0, 0, 0), HHFalloff(1, 3000, 0, 0.2, 0.9, 1, 1, 0, 0, 0), HHFalloff(0.1, 4000, 0, 0.01, 0.9, 1.2, 1, 0, 0, 0) }
	}
	presets.weapon.simple.is_rifle = {
		aim_delay = {
			0.1,
			0.2
		},
		focus_delay = 4, --4 sec focus delay build up, accuracy is based of number of enemies on the map, not on the assumption you're squaring off against a single enemy, being outnumbered does not equal being in trouble automatically, but rather, being outnumbered with enemies CLOSE to you is
		focus_dis = 100,
		spread = 40,
		miss_dis = 1,
		RELOAD_SPEED = 0.8,
		melee_speed = 1.5,
		melee_dmg = 2.5, --100 damage on melee, no joke
		melee_retry_delay = {
			1,
			1
		},
		tase_distance = 1500, --include tase parameters so that tasers can scale with difficulties better, since doing it the other way would keep reload speed, autofire rounds and other parameters unchanged
		aim_delay_tase = {
			0,
			0
		},
		tase_sphere_cast_radius = 5,
		range = HHRange(2000, 3000, 4000),
		autofire_rounds = { --autofire rounds match to 8-16, with low recoil to boot, should make hitting players consistent with 10 or more units at range
			1,
			5
		},
		FALLOFF = { HHFalloff(5, 100, 0, 0.1, 0.05, 0.15, 0, 0, 0, 1), HHFalloff(5, 500, 0, 0.1, 0.05, 0.15, 0, 0, 0, 1), HHFalloff(3, 1000, 0, 0.05, 0.1, 0.25, 0, 0, 0, 1), HHFalloff(2, 2000, 0, 0.025, 0.25, 0.35, 0, 0, 0, 1), HHFalloff(2, 3000, 0, 0.01, 0.25, 0.35, 0, 0, 0, 1), HHFalloff(0, 4000, 0, 0, 1, 2, 1, 0, 0, 0) }
	}
	presets.weapon.simple.is_bullpup = presets.weapon.simple.is_rifle
	presets.weapon.simple.is_shotgun_pump = {
		aim_delay = { --aim delay changed to match PDTH style aim-delay, might lower it later if shotgunners feel underpowered
			0,
			0.2
		},
		focus_delay = 7,
		focus_dis = 500, --focus delay only starts past 5m, cqc maps become dangerous fun houses while long-range maps encourage players to kite and keep enemies away
		spread = 20,
		miss_dis = 20,
		RELOAD_SPEED = 0.4, --lowered reload speed
		melee_speed = 1.5,
		melee_dmg = 10, --100 damage on melee, no joke, keep as is
		melee_retry_delay = {
			1,
			1
		},
		range = HHRange(800, 1000, 3000),
		FALLOFF = { HHFalloff(2, 100, 0, 0.9, 1, 1.15, 1, 0, 0, 0), HHFalloff(2, 500, 0, 0.9, 1, 1.15, 1, 0, 0, 0), HHFalloff(1.5, 1000, 0, 0.5, 1.35, 1.6, 1, 0, 0, 0), HHFalloff(1, 2000, 0, 0.25, 1.5, 2, 1, 0, 0, 0), HHFalloff(0.2, 3000, 0, 0.01, 2, 4, 1, 0, 0, 0) }
	}
	presets.weapon.simple.is_shotgun_mag = { --a mix of both shotgun and rifle, its a jack of all trades!
		aim_delay = { --aim delay changed to match PDTH style aim-delay.
			0,
			0.2
		},
		focus_delay = 3, --shotgun-like focus delay
		focus_dis = 500, --im sure its unescessary for me to keep commenting this now.
		spread = 20, --increased spread from regular shotgun
		miss_dis = 20,
		RELOAD_SPEED = 0.9, --saiga only has 7 shots per clip which forces a reload animation once depleted, justifying the rather quick reload
		melee_speed = 1.5,
		melee_dmg = 2,
		melee_retry_delay = {
			1,
			2
		},
		range = HHRange(800, 1500, 3000),
		autofire_rounds = { --autofire rounds
			1,
			3
		},
		--before i start falloff, if you can, go watch that one video of that one terrorist war crime guy eating a cyanide pill mid-trial to express my frustration at overkill simply cloning shotgun_pump for shotgun_mag
		FALLOFF = { HHFalloff(5, 100, 0.1, 0.9, 0.4, 0.8, 0, 3, 3, 1), HHFalloff(5, 500, 0.1, 0.9, 0.4, 0.8, 0, 3, 3, 1), HHFalloff(3, 1000, 0, 0.4, 0.6, 0.8, 0, 3, 3, 1), HHFalloff(2, 2000, 0, 0.2, 0.8, 1, 0, 3, 3, 1), HHFalloff(0.5, 3000, 0, 0.01, 1, 2, 1, 0, 0, 0) }
	}
	presets.weapon.simple.is_smg = { --used by hrts, cloakers and other sneaky buggers, generally not too scary damage-wise but does hella suppressive fire
		aim_delay = { --aim delay kept, the intent of the weapon is just to build suppression on the player and be generally annoying, its damage isnt worth too much consideration most of the time...MOST of the time.
			0.1,
			0.1
		},
		focus_delay = 4,
		focus_dis = 500, --then again, so was destroying all the spawngroups in housewarming update
		spread = 20,
		miss_dis = 20,
		RELOAD_SPEED = 1.1, --decreased slightly from normal
		melee_speed = 1.5,
		melee_dmg = 2.5,
		melee_retry_delay = {
			1,
			1
		},
		range = HHRange(1000, 2000, 4000),
		autofire_rounds = { --defined autofire for smgs.
			3,
			8
		},
		FALLOFF = { HHFalloff(4, 100, 0, 0.05, 0.1, 0.15, 0, 0, 0, 1), HHFalloff(4, 500, 0, 0.05, 0.1, 0.15, 0, 0, 0, 1), HHFalloff(3, 1000, 0, 0.025, 0.5, 0.9, 0, 0, 0, 1), HHFalloff(1, 2000, 0, 0.01, 0.6, 1.2, 0, 0, 0, 1), HHFalloff(0, 3000, 0, 0, 1.5, 3, 3, 1, 1, 0) }
	}
	presets.weapon.simple.is_revolver = {
		aim_delay = { --aim delay
			0.1,
			0.1
		},
		focus_delay = 5, --5 second focus delay, justified due to increased accuracy of the weapon along with damage scale
		focus_dis = 200,
		spread = 20,
		miss_dis = 50,
		RELOAD_SPEED = 0.9, --faster reloads than shotguns
		melee_speed = 1.5,
		melee_dmg = 2,
		melee_retry_delay = {
			1,
			2
		},
		range = HHRange(1000, 2000, 5000),
		FALLOFF = { HHFalloff(3, 100, 0, 0.9, 0.8, 1, 1, 0, 0, 0), HHFalloff(3, 500, 0, 0.9, 0.8, 1.1, 1, 0, 0, 0), HHFalloff(2.5, 1000, 0, 0.85, 0.8, 1.1, 1, 0, 0, 0), HHFalloff(2.5, 2000, 0, 0.7, 1, 1.1, 1, 0, 0, 0), HHFalloff(1, 3000, 0, 0.2, 1, 1.3, 1, 0, 0, 0), HHFalloff(0.2, 4000, 0, 0.01, 4, 5.5, 1, 0, 0, 0) }
	}
	presets.weapon.simple.mini = { --unused, its 4 am and im redoing the entire simple preset, im too tired to swear, for the love of god please help me
		aim_delay = {
			0.1,
			0.2
		},
		focus_delay = 3,
		focus_dis = 100,
		spread = 100, --bigger spread
		miss_dis = 1, --reduced miss dis to make it easier than complex
		RELOAD_SPEED = 0.5,
		melee_speed = 1.5,
		melee_dmg = 25,
		melee_retry_delay = {
			1,
			2
		},
		range = HHRange(1000, 1500, 1800),
		autofire_rounds = { --absolutely in awe of the size of this lad, absolute unit
			50,
			50
		},
		FALLOFF = { HHFalloff(7.5, 100, 1, 1, 4, 4, 0, 0, 0, 1), HHFalloff(7.5, 500, 1, 1, 4, 4, 0, 0, 0, 1), HHFalloff(4.5, 1000, 1, 1, 4, 4, 0, 0, 0, 1), HHFalloff(3, 2000, 0, 0.2, 4, 4, 0, 0, 0, 1), HHFalloff(1.5, 3000, 0, 0.1, 4, 4, 0, 0, 0, 1), HHFalloff(0, 4000, 0, 0.01, 4, 4, 0, 0, 0, 1) }
	}
	presets.weapon.simple.is_lmg = { --unused at this difficulty, based on complex
		aim_delay = { --this...is questionable but i feel increases fairness against lmg dozers just a bit.
			0.35,
			0.35
		},
		focus_delay = 0,
		focus_dis = 200,
		spread = 20,
		miss_dis = 40,
		RELOAD_SPEED = 0.5, --2 second pause after a full burst, theres 200 ammo in the fucking thing, it'll take time to empty, believe me.
		melee_speed = 1.5,
		melee_dmg = 15,
		melee_retry_delay = presets.weapon.expert.is_lmg.melee_retry_delay,
		range = HHRange(1000, 1500, 4000),
		autofire_rounds = {10, 30}, --bullet hose, kinda scary, fires in random, long bursts though
		FALLOFF = { HHFalloff(4, 100, 1, 1, 0.4, 0.8, 0, 0, 0, 1), HHFalloff(4, 500, 1, 1, 0.4, 0.8, 0, 0, 0, 1), HHFalloff(4, 1000, 1, 1, 0.6, 1.0, 0, 0, 0, 1), HHFalloff(2, 2000, 1, 1, 0.8, 1.2, 0, 0, 0, 1), HHFalloff(0.5, 3000, 1, 1, 0.8, 1.2, 0, 0, 0, 1), HHFalloff(0, 4000, 1, 1, 2, 3, 1, 0, 0, 0) }
	}
	presets.weapon.simple.is_flamethrower = {
		aim_delay = {
			0.5,
			0.5
		},
		focus_delay = 0,
		focus_dis = 300,
		spread = 0,
		miss_dis = 40,
		RELOAD_SPEED = 0.6,
		melee_speed = 1,
		melee_dmg = 2,
		melee_retry_delay = {
			1,
			2
		},
		range = HHRange(1400, 400, 1700),
		autofire_rounds = {
			20,
			40
		},
		FALLOFF = { HHFalloff(8, 400, 1, 1, 0.45, 0.65, 0, 0, 0, 1), HHFalloff(4, 1000, 1, 1, 0.75, 1, 0, 0, 0, 1), HHFalloff(2, 2000, 1, 1, 0.75, 1, 0, 0, 0, 1), HHFalloff(1, 3000, 1, 1, 0.75, 1, 0, 0, 0, 1) }
	}

	--civil begins here, noteworthy change being increases in attack rate along with less falloff, plus the increase of focus delay minimum starting range
	presets.weapon.civil.is_pistol = {
		aim_delay = { --no aim delay
			0.6,
			0.6
		},
		focus_delay = 1.5,
		focus_dis = 100,
		spread = 25,
		miss_dis = 30,
		RELOAD_SPEED = 1.25,
		melee_speed = 0.5,
		melee_dmg = 10,
		tracking_speed = 900,
		melee_retry_delay = {
			1,
			1
		},
		range = HHRange(1000, 2000, 4000),
		FALLOFF = { HHFalloff(3, 500, 0.2, 0.9, 0.25, 0.35, 1, 0, 0, 0), HHFalloff(1.5, 1000, 0, 0.45, 0.3, 0.4, 1, 0, 0, 0), HHFalloff(0, 3000, 0, 0, 0.4, 1, 1, 0, 0, 0) }
	}
	presets.weapon.civil.akimbo_pistol = { --akimbos cosmetic
		aim_delay = { --no aim delay
			0.6,
			0.6
		},
		focus_delay = 1.5,
		focus_dis = 100,
		spread = 25,
		miss_dis = 30,
		RELOAD_SPEED = 1.25,
		melee_speed = 0.5,
		melee_dmg = 10,
		tracking_speed = 900,
		melee_retry_delay = {
			1,
			1
		},
		range = HHRange(1000, 2000, 4000),
		FALLOFF = { HHFalloff(3, 500, 0.2, 0.9, 0.25, 0.35, 1, 0, 0, 0), HHFalloff(1.5, 1000, 0, 0.45, 0.3, 0.4, 1, 0, 0, 0), HHFalloff(0, 3000, 0, 0, 0.4, 1, 1, 0, 0, 0) }
	}
	presets.weapon.civil.is_rifle = {
		aim_delay = {
			0.5,
			0.5
		},
		focus_delay = 1,
		focus_dis = 100,
		spread = 28,
		miss_dis = 40,
		RELOAD_SPEED = 1,
		melee_speed = 0.5,
		melee_dmg = 10, --100 damage on melee
		melee_retry_delay = {
			1,
			1
		},
		tracking_speed = 900,
		tase_distance = 1500,
		aim_delay_tase = {
			0,
			0
		},
		tase_sphere_cast_radius = 5,
		range = HHRange(1600, 3000, 4000),
		autofire_rounds = { --yes.
			1,
			5
		},
		FALLOFF = { HHFalloff(3, 400, 0.9, 1, 0.4, 0.8, 0, 0, 0, 1), HHFalloff(3, 800, 0, 0.9, 0.4, 0.8, 0, 0, 0, 1), HHFalloff(2, 1200, 0, 0.7, 0.4, 0.8, 0, 0, 0, 1), HHFalloff(1, 2000, 0, 0.5, 0.6, 1, 0, 0, 0, 1), HHFalloff(1, 4000, 0, 0.1, 0.8, 1.2, 0, 0, 0, 1) }
	}
	presets.weapon.civil.is_bullpup = presets.weapon.civil.is_rifle
	presets.weapon.civil.is_shotgun_pump = {
		aim_delay = {
			0.9,
			0.9
		},
		focus_delay = 1.25, --focus delay change here.
		focus_dis = 100, --focus delay only starts past 5m
		spread = 15,
		miss_dis = 20,
		RELOAD_SPEED = 1.4, --HOW? ARE THEY JUST PILING ALL THE SHELLS ON THEIR HAND AND JUST SHOVING IT IN THERE LIKE CANDY INTO A BOWL???? either way, quite powerful
		melee_speed = 0.5,
		melee_dmg = 15, --100 damage on melee, no joke, keep as is from civil and up
		melee_retry_delay = {
			1,
			1
		},
		tracking_speed = 500,
		range = HHRange(1200, 2000, 3000, 600),
		FALLOFF = { HHFalloff(2, 400, 0.6, 1, 0.8, 1, 1, 0, 0, 0), HHFalloff(1.5, 800, 0.2, 0.9, 1, 1.2, 1, 0, 0, 0), HHFalloff(1, 1000, 0, 0.75, 1.1, 1.3, 1, 0, 0, 0), HHFalloff(1, 1200, 0, 0.25, 1.1, 1.3, 1, 0, 0, 0), HHFalloff(0, 3000, 0, 0, 2, 4, 1, 0, 0, 0) }
	}
	presets.weapon.civil.is_shotgun_mag = { --yeehaw
		aim_delay = {
			0,
			0
		},
		focus_delay = 1.4,
		focus_dis = 100, --unchanged from civil.
		spread = 20,
		miss_dis = 20,
		RELOAD_SPEED = 1.4, --whew.
		melee_speed = 0.5,
		melee_dmg = 23,
		fireline_t = 0.35, --how long it takes for enemies to reset their focus and aim delay.
		melee_retry_delay = {
			1,
			2
		},
		tracking_speed = 700,
		range = HHRange(1000, 2500, 4000, 400),
		autofire_rounds = { --not used anymore
			1,
			3
		},
		--wow remember when i thought i was a he that shit was wack lol
		FALLOFF = { HHFalloff(2, 400, 0, 0.9, 0.4, 0.5, 1, 0, 0, 0), HHFalloff(1.7, 800, 0, 0.5, 0.6, 0.8, 1, 0, 0, 0), HHFalloff(1, 1500, 0, 0.25, 0.7, 1.4, 1, 0, 0, 0), HHFalloff(1, 3000, 0, 0, 1.05, 1.75, 1, 0, 0, 0) }
	}
	presets.weapon.civil.is_smg = { --used by hrts, light swats, cloakers and other sneaky buggers, generally not too scary damage-wise but does hella suppressive fire
		aim_delay = {
			0.6,
			0.6
		},
		focus_delay = 1.2,
		focus_dis = 100,
		spread = 25,
		miss_dis = 40,
		RELOAD_SPEED = 1.5, --whew.
		melee_speed = 0.5,
		melee_dmg = 15,
		melee_retry_delay = {
			1,
			1
		},
		tracking_speed = 1100,
		range = HHRange(1000, 3500, 4000),
		autofire_rounds = { --extended mags a ton, pretty hazardous and continuous
			3,
			8
		},
		FALLOFF = { HHFalloff(2, 500, 0, 0.75, 0.2, 0.2, 0, 0, 0, 1), HHFalloff(1, 1000, 0, 0.5, 0.2, 0.2, 0, 0, 0, 1), HHFalloff(1, 2000, 0, 0.2, 0.2, 0.2, 0, 0, 0, 1) }
	}
	presets.weapon.civil.is_revolver = { --used by punks and beat police
		aim_delay = {
			0.6,
			0.6
		},
		focus_delay = 3, --3 second focus delay, justified due to increased accuracy of the weapon along with damage scale
		focus_dis = 100,
		spread = 10,
		miss_dis = 10,
		RELOAD_SPEED = 1.4,
		melee_speed = 0.5,
		melee_dmg = 10,
		melee_retry_delay = {
			1,
			2
		},
		tracking_speed = 800,
		range = HHRange(1000, 2000, 5000),
		FALLOFF = { HHFalloff(2, 1000, 0, 0.9, 1, 1.2, 1, 0, 0, 0), HHFalloff(1, 2000, 0, 0.85, 1.2, 1.4, 1, 0, 0, 0), HHFalloff(0, 3000, 0, 0, 4, 5.5, 1, 0, 0, 0) }
	}
	presets.weapon.civil.mini = { --my wrath is finally............gone...........
		spread_only = true,
		aim_delay = {
			0.9,
			0.9
		},
		focus_delay = 2,
		focus_dis = 100,
		spread = 60,
		miss_dis = 10,
		RELOAD_SPEED = 0.5,
		melee_speed = 0.5,
		melee_dmg = 25,
		melee_retry_delay = {
			1,
			2
		},
		tracking_speed = 400,
		range = HHRange(1000, 1500, 10000),
		autofire_rounds = { --absolutely in awe of the size of this lad, absolute unit
			100,
			100
		},
		FALLOFF = { HHFalloff(7.5, 1000, 120, 60, 2, 2, 0, 0, 0, 1), HHFalloff(3.75, 2000, 120, 60, 2, 2, 0, 0, 0, 1), HHFalloff(1.5, 10000, 140, 80, 2, 2, 0, 0, 0, 1), HHFalloff(0, 20000, 140, 80, 2, 2, 0, 0, 0, 1) }
	}
	presets.weapon.civil.is_lmg = { --LMG dozer, usage defined on weapontweakdata to suit it
		spread_only = true,
		aim_delay = {
			0.7,
			0.7
		},
		focus_delay = 3,
		focus_dis = 100,
		spread = 20,
		miss_dis = 10,
		RELOAD_SPEED = 1, --theres 200 ammo in the fucking thing, it'll take time to empty
		melee_speed = 0.5,
		melee_dmg = 20,
		melee_retry_delay = presets.weapon.expert.is_lmg.melee_retry_delay,
		range = HHRange(1000, 1500, 4000, 500),
		tracking_speed = 800,
		autofire_rounds = {10, 30}, --bullet hose, kinda scary, fires in random, long bursts though
		FALLOFF = { HHFalloff(3, 500, 40, 9, 0.8, 0.8, 0, 0, 0, 1), HHFalloff(3, 1000, 40, 9, 0.8, 0.8, 0, 0, 0, 1), HHFalloff(2, 2000, 40, 9, 0.8, 0.8, 0, 0, 0, 1), HHFalloff(1, 3000, 50, 12, 0.8, 0.8, 0, 0, 0, 1), HHFalloff(0, 4000, 50, 12, 0.8, 0.8, 0, 0, 0, 1) }
	}
	presets.weapon.civil.is_flamethrower = {
		aim_delay = {
			0.5,
			0.5
		},
		focus_delay = 0,
		focus_dis = 300,
		spread = 0,
		miss_dis = 40,
		RELOAD_SPEED = 0.6,
		melee_speed = 1,
		melee_dmg = 2,
		melee_retry_delay = {
			1,
			2
		},
		range = HHRange(1400, 400, 1700),
		autofire_rounds = {
			20,
			40
		},
		tracking_speed = 700,
		FALLOFF = { HHFalloff(8, 400, 1, 1, 0.45, 0.65, 0, 0, 0, 1), HHFalloff(4, 1000, 1, 1, 0.75, 1, 0, 0, 0, 1), HHFalloff(2, 2000, 1, 1, 0.75, 1, 0, 0, 0, 1), HHFalloff(1, 3000, 1, 1, 0.75, 1, 0, 0, 0, 1) }
	}


	--complex begins here, focus delay, recoil and reloads get reduced, there are tweaks to autofire and falloff as well, enemy damage is not changed, worthwhile changes will be done in weapontweakdata to increase firing frequency and such

	presets.weapon.complex.is_pistol = {
		aim_delay = { --no aim delay
			0.5,
			0.5
		},
		focus_delay = 1,
		focus_dis = 100,
		spread = 25,
		miss_dis = 30,
		RELOAD_SPEED = 1.25,
		melee_speed = 0.5,
		melee_dmg = 10,
		melee_retry_delay = {
			1,
			1
		},
		tracking_speed = presets.weapon.civil.is_pistol.tracking_speed,
		range = HHRange(1000, 2000, 4000),
		FALLOFF = { HHFalloff(3, 500, 0.2, 0.9, 0.25, 0.35, 1, 0, 0, 0), HHFalloff(2, 1000, 0, 0.6, 0.3, 0.4, 1, 0, 0, 0), HHFalloff(1, 2000, 0, 0.45, 0.3, 0.45, 1, 0, 0, 0), HHFalloff(0, 3000, 0, 0, 0.4, 1, 1, 0, 0, 0) }
	}
	presets.weapon.complex.akimbo_pistol = { --akimbos cosmetic
		aim_delay = { --no aim delay
			0.5,
			0.5
		},
		focus_delay = 1,
		focus_dis = 100,
		spread = 25,
		miss_dis = 30,
		RELOAD_SPEED = 1.25,
		melee_speed = 0.5,
		melee_dmg = 10,
		melee_retry_delay = {
			1,
			1
		},
		tracking_speed = presets.weapon.civil.akimbo_pistol.tracking_speed,
		range = HHRange(1000, 2000, 4000),
		FALLOFF = { HHFalloff(3, 500, 0.2, 0.9, 0.25, 0.35, 1, 0, 0, 0), HHFalloff(2, 1000, 0, 0.6, 0.3, 0.4, 1, 0, 0, 0), HHFalloff(1, 2000, 0, 0.45, 0.3, 0.45, 1, 0, 0, 0), HHFalloff(0, 3000, 0, 0, 0.4, 1, 1, 0, 0, 0) }
	}
	presets.weapon.complex.is_rifle = {
		aim_delay = {
			0.5,
			0.5
		},
		focus_delay = 1,
		focus_dis = 100,
		spread = 20,
		miss_dis = 20,
		RELOAD_SPEED = 1.25,
		melee_speed = 0.5,
		melee_dmg = 10, --100 damage on melee
		melee_retry_delay = {
			1,
			1
		},
		tase_distance = 1500,
		aim_delay_tase = {
			0,
			0
		},
		tase_sphere_cast_radius = 5,
		range = HHRange(1600, 3000, 4000),
		tracking_speed = presets.weapon.civil.is_rifle.tracking_speed,
		autofire_rounds = { --yes.
			1,
			5
		},
		FALLOFF = { HHFalloff(4.5, 400, 0.9, 1, 0.4, 0.8, 0, 0, 0, 1), HHFalloff(3, 800, 0.2, 0.9, 0.4, 0.8, 0, 0, 0, 1), HHFalloff(2, 1200, 0, 0.7, 0.4, 0.8, 0, 0, 0, 1), HHFalloff(2, 2000, 0, 0.5, 0.6, 1, 0, 0, 0, 1), HHFalloff(1, 3000, 0, 0.3, 0.6, 1, 0, 0, 0, 1), HHFalloff(1, 4000, 0, 0.1, 0.8, 1.2, 0, 0, 0, 1) }
	}
	presets.weapon.complex.is_bullpup = presets.weapon.complex.is_rifle
	presets.weapon.complex.is_shotgun_pump = {
		aim_delay = {
			0.8,
			0.8
		},
		focus_delay = 1, --focus delay change here.
		focus_dis = 100, --focus delay only starts past 5m
		spread = 15,
		miss_dis = 20,
		RELOAD_SPEED = 1.4, --HOW? ARE THEY JUST PILING ALL THE SHELLS ON THEIR HAND AND JUST SHOVING IT IN THERE LIKE CANDY INTO A BOWL???? either way, quite powerful
		melee_speed = 0.5,
		melee_dmg = 15, --100 damage on melee, no joke, keep as is from civil and up
		melee_retry_delay = {
			1,
			1
		},
		range = HHRange(1200, 2000, 3000, 600),
		tracking_speed = presets.weapon.civil.is_shotgun_pump.tracking_speed,
		FALLOFF = { HHFalloff(3, 400, 0.9, 1, 0.8, 0.9, 1, 0, 0, 0), HHFalloff(3, 800, 0.3, 0.9, 0.9, 1, 1, 0, 0, 0), HHFalloff(2, 1000, 0.1, 0.75, 1, 1.3, 1, 0, 0, 0), HHFalloff(1, 1500, 0, 0.25, 1.1, 1.3, 1, 0, 0, 0), HHFalloff(0, 3000, 0, 0, 2, 4, 1, 0, 0, 0) }
	}
	presets.weapon.complex.is_shotgun_mag = { --yeehaw
		aim_delay = {
			0,
			0
		},
		focus_delay = 1.05,
		focus_dis = 100, --unchanged from civil.
		spread = 20,
		miss_dis = 20,
		RELOAD_SPEED = 1.4, --whew.
		melee_speed = 0.5,
		melee_dmg = 23,
		fireline_t = 0.35, --how long it takes for enemies to reset their focus and aim delay.
		melee_retry_delay = {
			1,
			2
		},
		range = HHRange(1000, 2500, 4000, 400),
		tracking_speed = presets.weapon.civil.is_shotgun_mag.tracking_speed,
		autofire_rounds = { --not used anymore
			1,
			3
		},
		--wow remember when i thought i was a he that shit was wack lol
		FALLOFF = { HHFalloff(2, 400, 0.25, 0.9, 0.4, 0.5, 1, 0, 0, 0), HHFalloff(1.7, 1000, 0.1, 0.5, 0.6, 0.7, 1, 0, 0, 0), HHFalloff(1, 2000, 0, 0.25, 0.7, 1.4, 1, 0, 0, 0), HHFalloff(1, 3000, 0, 0, 1.05, 1.75, 1, 0, 0, 0) }
	}
	presets.weapon.complex.is_smg = { --used by hrts, light swats, cloakers and other sneaky buggers, generally not too scary damage-wise but does hella suppressive fire
		aim_delay = {
			0.5,
			0.5
		},
		focus_delay = 1.1,
		focus_dis = 100,
		spread = 25,
		miss_dis = 30,
		RELOAD_SPEED = 1.5, --whew.
		melee_speed = 0.5,
		melee_dmg = 15,
		melee_retry_delay = {
			1,
			1
		},
		range = HHRange(1000, 3500, 4000),
		tracking_speed = presets.weapon.civil.is_smg.tracking_speed,
		autofire_rounds = { --extended mags a ton, pretty hazardous and continuous
			3,
			8
		},
		FALLOFF = { HHFalloff(3, 500, 0.2, 0.75, 0.2, 0.2, 0, 0, 0, 1), HHFalloff(2, 1000, 0.05, 0.6, 0.2, 0.2, 0, 0, 0, 1), HHFalloff(1, 1500, 0, 0.4, 0.2, 0.2, 0, 0, 0, 1), HHFalloff(1, 3000, 0, 0.2, 0.2, 0.2, 0, 0, 0, 1) }
	}
	presets.weapon.complex.is_revolver = { --used by punks and beat police
		aim_delay = {
			0.5,
			0.5
		},
		focus_delay = 3, --3 second focus delay, justified due to increased accuracy of the weapon along with damage scale
		focus_dis = 100,
		spread = 10,
		miss_dis = 10,
		RELOAD_SPEED = 1.8, --FAST reload.
		melee_speed = 0.5,
		melee_dmg = 10,
		melee_retry_delay = {
			1,
			2
		},
		range = HHRange(1000, 2000, 5000),
		tracking_speed = presets.weapon.civil.is_revolver.tracking_speed,
		FALLOFF = { HHFalloff(3, 1000, 0, 0.9, 1, 1.2, 1, 0, 0, 0), HHFalloff(2.5, 2000, 0, 0.85, 1.2, 1.4, 1, 0, 0, 0), HHFalloff(1.88, 3000, 0, 0.25, 1.4, 1.6, 1, 0, 0, 0), HHFalloff(0, 4000, 0, 0, 4, 5.5, 1, 0, 0, 0) }
	}
	presets.weapon.complex.mini = { --my wrath is finally............gone...........
		spread_only = true,
		aim_delay = {
			0.8,
			0.8
		},
		focus_delay = 2,
		focus_dis = 100,
		spread = 60,
		miss_dis = 10,
		RELOAD_SPEED = 0.5,
		melee_speed = 0.5,
		melee_dmg = 25,
		melee_retry_delay = {
			1,
			2
		},
		tracking_speed = presets.weapon.civil.mini.tracking_speed,
		range = HHRange(1000, 1500, 10000),
		autofire_rounds = { --absolutely in awe of the size of this lad, absolute unit
			100,
			100
		},
		FALLOFF = { HHFalloff(7.5, 1000, 120, 60, 2, 2, 0, 0, 0, 1), HHFalloff(3.75, 2000, 120, 60, 2, 2, 0, 0, 0, 1), HHFalloff(1.5, 10000, 140, 80, 2, 2, 0, 0, 0, 1), HHFalloff(0, 20000, 140, 80, 2, 2, 0, 0, 0, 1) }
	}
	presets.weapon.complex.is_lmg = { --LMG dozer, usage defined on weapontweakdata to suit it
		spread_only = true,
		aim_delay = {
			0.6,
			0.6
		},
		focus_delay = 3,
		focus_dis = 100,
		spread = 20,
		miss_dis = 10,
		RELOAD_SPEED = 1, --theres 200 ammo in the fucking thing, it'll take time to empty
		melee_speed = 0.5,
		melee_dmg = 20,
		melee_retry_delay = presets.weapon.expert.is_lmg.melee_retry_delay,
		range = HHRange(1000, 1500, 4000, 500),
		tracking_speed = presets.weapon.civil.is_lmg.tracking_speed,
		autofire_rounds = {10, 30}, --bullet hose, kinda scary, fires in random, long bursts though
		FALLOFF = { HHFalloff(3, 500, 40, 9, 0.8, 0.8, 0, 0, 0, 1), HHFalloff(3, 1000, 40, 9, 0.8, 0.8, 0, 0, 0, 1), HHFalloff(2, 2000, 40, 9, 0.8, 0.8, 0, 0, 0, 1), HHFalloff(1, 3000, 50, 12, 0.8, 0.8, 0, 0, 0, 1), HHFalloff(0, 4000, 50, 12, 0.8, 0.8, 0, 0, 0, 1) }
	}
	presets.weapon.complex.is_flamethrower = {
		aim_delay = {
			0.5,
			0.5
		},
		focus_delay = 0,
		focus_dis = 300,
		spread = 0,
		miss_dis = 40,
		RELOAD_SPEED = 0.6,
		melee_speed = 1,
		melee_dmg = 2,
		melee_retry_delay = {
			1,
			2
		},
		range = HHRange(1400, 400, 1700),
		autofire_rounds = {
			20,
			40
		},
		tracking_speed = presets.weapon.civil.is_flamethrower.tracking_speed,
		FALLOFF = { HHFalloff(8, 400, 1, 1, 0.45, 0.65, 0, 0, 0, 1), HHFalloff(6, 1000, 1, 1, 0.75, 1, 0, 0, 0, 1), HHFalloff(2, 2000, 1, 1, 0.75, 1, 0, 0, 0, 1), HHFalloff(1, 3000, 1, 1, 0.75, 1, 0, 0, 0, 1) }
	}

	--anarchy begins here, all damage increased slightly, firing ranges are increased dramatically, and gun damage is mostly flat until a sudden skydive at 40m, minor acc or recoil changes, none of that is particularly as bad as the zeal spawngroups in this difficulty however, which can, and will, tear out your asshole through your mouth

	presets.weapon.anarchy.is_pistol = {
		aim_delay = { --no aim delay
			0.4,
			0.4
		},
		focus_delay = 1,
		focus_dis = 100,
		spread = 25,
		miss_dis = 30,
		RELOAD_SPEED = 1.4, --slight reduction from civil
		melee_speed = 0.5,
		melee_dmg = 10,
		melee_retry_delay = {
			1,
			1
		},
		tracking_speed = presets.weapon.civil.is_pistol.tracking_speed,
		range = HHRange(1000, 2000, 4000),
		FALLOFF = { HHFalloff(4, 500, 0.2, 0.9, 0.25, 0.35, 1, 0, 0, 0), HHFalloff(4, 1000, 0, 0.6, 0.3, 0.4, 1, 0, 0, 0), HHFalloff(2, 2000, 0, 0.45, 0.3, 0.45, 1, 0, 0, 0), HHFalloff(2, 3000, 0, 0.25, 0.35, 1, 1, 0, 0, 0), HHFalloff(0.1, 4000, 0, 0.01, 0.4, 1, 1, 0, 0, 0) }
	}
	presets.weapon.anarchy.akimbo_pistol = { --akimbos cosmetic
		aim_delay = { --no aim delay
			0.4,
			0.4
		},
		focus_delay = 1,
		focus_dis = 100,
		spread = 25,
		miss_dis = 30,
		RELOAD_SPEED = 1.4, --slight reduction from civil
		melee_speed = 0.5,
		melee_dmg = 10,
		melee_retry_delay = {
			1,
			1
		},
		tracking_speed = presets.weapon.civil.akimbo_pistol.tracking_speed,
		range = HHRange(1000, 4000, 4000),
		FALLOFF = { HHFalloff(4, 500, 0.2, 0.9, 0.25, 0.35, 1, 0, 0, 0), HHFalloff(4, 1000, 0, 0.6, 0.3, 0.4, 1, 0, 0, 0), HHFalloff(2, 2000, 0, 0.45, 0.3, 0.45, 1, 0, 0, 0), HHFalloff(2, 3000, 0, 0.25, 0.35, 1, 1, 0, 0, 0), HHFalloff(0, 4000, 0, 0.01, 0.4, 1, 1, 0, 0, 0) }
	}
	presets.weapon.anarchy.is_rifle = {
		aim_delay = {
			0.5,
			0.5
		},
		focus_delay = 1,
		focus_dis = 100,
		spread = 20,
		miss_dis = 10,
		RELOAD_SPEED = 1.4, --DW style.
		melee_speed = 0.5,
		melee_dmg = 15,
		melee_retry_delay = {
			1,
			1
		},
		tase_distance = 1500,
		aim_delay_tase = {
			0,
			0
		},
		tase_sphere_cast_radius = 5,
		range = HHRange(2000, 3000, 4000),
		tracking_speed = presets.weapon.civil.is_rifle.tracking_speed,
		autofire_rounds = { --yes.
			1,
			5
		},
		FALLOFF = { HHFalloff(6, 400, 0.9, 1, 0.4, 0.8, 0, 0, 0, 1), HHFalloff(5, 800, 0.3, 0.9, 0.4, 0.8, 0, 0, 0, 1), HHFalloff(5, 1200, 0, 0.7, 0.4, 0.8, 0, 0, 0, 1), HHFalloff(4, 2000, 0, 0.5, 0.6, 1, 0, 0, 0, 1), HHFalloff(3, 3000, 0, 0.4, 0.6, 1, 0, 0, 0, 1), HHFalloff(3, 4000, 0, 0.4, 0.6, 1, 0, 0, 0, 1), HHFalloff(2, 5000, 0, 0.1, 0.6, 1, 0, 0, 0, 1) }
	}
	presets.weapon.anarchy.is_bullpup = presets.weapon.anarchy.is_rifle
	presets.weapon.anarchy.is_shotgun_pump = {
		aim_delay = {
			0.7,
			0.7
		},
		focus_delay = 0.8, --focus delay change here.
		focus_dis = 100,
		spread = 15,
		miss_dis = 20,
		RELOAD_SPEED = 1.4, --HOW? ARE THEY JUST PILING ALL THE SHELLS ON THEIR HAND AND JUST SHOVING IT IN THERE LIKE CANDY INTO A BOWL???? either way, quite powerful
		melee_speed = 0.5,
		melee_dmg = 15, --100 damage on melee, no joke, keep as is from civil and up
		melee_retry_delay = {
			1,
			1
		},
		tracking_speed = presets.weapon.civil.is_shotgun_pump.tracking_speed,
		range = HHRange(1200, 2000, 3000, 600),
		FALLOFF = { HHFalloff(3, 400, 0.9, 1, 0.65, 0.8, 1, 0, 0, 0), HHFalloff(3, 800, 0.3, 0.9, 0.7, 0.9, 1, 0, 0, 0), HHFalloff(2, 1000, 0.15, 0.75, 0.8, 1, 1, 0, 0, 0), HHFalloff(2, 1500, 0.05, 0.5, 0.9, 1.1, 1, 0, 0, 0), HHFalloff(1, 2000, 0, 0.25, 1, 1.3, 1, 0, 0, 0), HHFalloff(0, 3000, 0, 0, 2, 4, 1, 0, 0, 0) }
	}
	presets.weapon.anarchy.is_shotgun_mag = { --JUGGERNAUT RHGHGHGHGHG
		aim_delay = {
			0,
			0
		},
		focus_delay = 0.7,
		focus_dis = 100, --unchanged from civil.
		spread = 20,
		miss_dis = 80,
		RELOAD_SPEED = 1.4, --whew.
		melee_speed = 0.5,
		melee_dmg = 23,
		fireline_t = 0.35, --how long it takes for enemies to reset their focus and aim delay.
		melee_retry_delay = {
			1,
			2
		},
		range = HHRange(1000, 2500, 4000, 400),
		tracking_speed = presets.weapon.civil.is_shotgun_mag.tracking_speed,
		autofire_rounds = { --not used anymore
			1,
			3
		},
		--wow remember when i thought i was a he that shit was wack lol
		FALLOFF = { HHFalloff(2, 600, 0.25, 0.9, 0.36, 0.36, 1, 0, 0, 0), HHFalloff(1.7, 1200, 0.1, 0.5, 0.36, 1.05, 1, 0, 0, 0), HHFalloff(1, 2500, 0, 0.25, 0.6, 1.4, 1, 0, 0, 0), HHFalloff(1, 3000, 0, 0, 0.6, 1.75, 1, 0, 0, 0) }
	}
	presets.weapon.anarchy.is_smg = { --used by hrts, light swats, cloakers and other sneaky buggers, generally not too scary damage-wise but does hella suppressive fire
		aim_delay = {
			0.4,
			0.4
		},
		focus_delay = 1,
		focus_dis = 100,
		spread = 20,
		miss_dis = 20,
		RELOAD_SPEED = 2, --whew.
		melee_speed = 0.5,
		melee_dmg = 15,
		melee_retry_delay = {
			1,
			1
		},
		range = HHRange(1000, 3500, 4000),
		tracking_speed = presets.weapon.civil.is_smg.tracking_speed,
		autofire_rounds = { --extended mags a ton, pretty hazardous and continuous
			3,
			8
		},
		FALLOFF = { HHFalloff(4, 500, 0.2, 0.75, 0.2, 0.2, 0, 0, 0, 1), HHFalloff(3, 1000, 0.05, 0.6, 0.2, 0.2, 0, 0, 0, 1), HHFalloff(1, 2000, 0, 0.4, 0.2, 0.2, 0, 0, 0, 1), HHFalloff(1, 3000, 0, 0.2, 0.2, 0.2, 0, 0, 0, 1) }
	}
	presets.weapon.anarchy.is_revolver = { --used for by punks, and beat police
		aim_delay = {
			0.4,
			0.4
		},
		focus_delay = 3, --3 second focus delay, justified due to increased accuracy of the weapon along with damage scale
		focus_dis = 100,
		spread = 10,
		miss_dis = 10,
		RELOAD_SPEED = 1.8, --FAST reload.
		melee_speed = 0.5,
		melee_dmg = 10,
		melee_retry_delay = {
			1,
			2
		},
		range = HHRange(2000, 3000, 5000),
		tracking_speed = presets.weapon.civil.is_revolver.tracking_speed,
		FALLOFF = { HHFalloff(3, 1000, 0, 0.9, 0.64, 1, 1, 0, 0, 0), HHFalloff(2.5, 2000, 0, 0.85, 0.75, 1.2, 1, 0, 0, 0), HHFalloff(1.88, 3000, 0, 0.25, 1, 1.3, 1, 0, 0, 0), HHFalloff(0, 4000, 0, 0, 4, 5.5, 1, 0, 0, 0) }
	}
	presets.weapon.anarchy.mini = { --my wrath is finally............gone...........
		spread_only = true,
		aim_delay = {
			0.7,
			0.7
		},
		focus_delay = 1.25,
		focus_dis = 100,
		spread = 60,
		miss_dis = 10,
		RELOAD_SPEED = 0.5,
		melee_speed = 0.5,
		melee_dmg = 25,
		melee_retry_delay = {
			1,
			2
		},
		range = HHRange(1000, 1500, 10000),
		tracking_speed = presets.weapon.civil.mini.tracking_speed,
		autofire_rounds = { --absolutely in awe of the size of this lad, absolute unit
			100,
			100
		},
		FALLOFF = { HHFalloff(7.5, 1000, 50, 30, 2, 2, 0, 0, 0, 1), HHFalloff(3.75, 2000, 80, 50, 2, 2, 0, 0, 0, 1), HHFalloff(3.75, 10000, 90, 60, 2, 2, 0, 0, 0, 1), HHFalloff(0, 20000, 90, 60, 2, 2, 0, 0, 0, 1) }
	}
	presets.weapon.anarchy.is_lmg = { --LMG dozer, usage defined on weapontweakdata to suit it
		spread_only = true,
		aim_delay = {
			0.5,
			0.5
		},
		focus_delay = 3,
		focus_dis = 100,
		spread = 20,
		miss_dis = 10,
		RELOAD_SPEED = 1.15, --theres 200 ammo in the fucking thing, it'll take time to empty
		melee_speed = 0.5,
		melee_dmg = 20,
		melee_retry_delay = presets.weapon.expert.is_lmg.melee_retry_delay,
		range = HHRange(1000, 1500, 4000, 500),
		tracking_speed = presets.weapon.civil.is_lmg.tracking_speed,
		autofire_rounds = {10, 30}, --bullet hose, kinda scary, fires in random, long bursts though
		FALLOFF = { HHFalloff(3, 100, 20, 3, 0.8, 0.8, 0, 0, 0, 1), HHFalloff(3, 500, 20, 3, 0.8, 0.8, 0, 0, 0, 1), HHFalloff(3, 1000, 20, 3, 0.8, 0.8, 0, 0, 0, 1), HHFalloff(2, 2000, 20, 6, 0.8, 0.8, 0, 0, 0, 1), HHFalloff(2, 3000, 30, 9, 0.8, 0.8, 0, 0, 0, 1), HHFalloff(0, 4000, 30, 12, 2, 3, 0, 0, 0, 1) }
	}
	presets.weapon.anarchy.is_flamethrower = {
		aim_delay = {
			0.5,
			0.5
		},
		focus_delay = 0,
		focus_dis = 300,
		spread = 0,
		miss_dis = 40,
		RELOAD_SPEED = 0.6,
		melee_speed = 1,
		melee_dmg = 2,
		melee_retry_delay = {
			1,
			2
		},
		range = HHRange(1400, 400, 1700),
		tracking_speed = presets.weapon.civil.is_flamethrower.tracking_speed,
		autofire_rounds = {
			20,
			40
		},
		FALLOFF = { HHFalloff(12, 400, 1, 1, 0.45, 0.65, 0, 0, 0, 1), HHFalloff(6, 1000, 1, 1, 0.75, 1, 0, 0, 0, 1), HHFalloff(2, 2000, 1, 1, 0.75, 1, 0, 0, 0, 1), HHFalloff(1, 3000, 1, 1, 0.75, 1, 0, 0, 0, 1) }
	}

	presets.weapon.fbigod = deep_clone(presets.weapon.anarchy)

	presets.weapon.fbigod.is_pistol = { --Only used by FBIs on Anarchy, they're tough guys.
		aim_delay = {
			0.6,
			0.6
		},
		focus_delay = 0.7, --focus delay.
		focus_dis = 500,
		spread = 10,
		miss_dis = 5,
		RELOAD_SPEED = 2.1, --Fast reloads.
		melee_speed = 0.75,
		melee_dmg = 22,
		melee_retry_delay = {
			1,
			1
		},
		range = HHRange(2000, 2500, 3000),
		FALLOFF = { HHFalloff(6, 100, 0.1, 0.9, 0.18, 0.2, 1, 0, 0, 0), HHFalloff(6, 500, 0.1, 0.85, 0.18, 0.2, 1, 0, 0, 0), HHFalloff(6, 1000, 0, 0.7, 0.18, 0.2, 1, 0, 0, 0), HHFalloff(4, 2000, 0, 0.5, 0.18, 0.2, 1, 0, 0, 0), HHFalloff(4, 3000, 0, 0.35, 0.18, 0.2, 1, 0, 0, 0), HHFalloff(0, 4000, 0, 0, 0.18, 0.2, 1, 0, 0, 0) }
	}
	presets.weapon.fbigod.akimbo_pistol = { --oh boy why didnt i do this earlier
		aim_delay = {
			0.6,
			0.6
		},
		focus_delay = 0.7, --focus delay.
		focus_dis = 500,
		spread = 10,
		miss_dis = 5,
		RELOAD_SPEED = 2.1, --Fast reloads.
		melee_speed = 0.75,
		melee_dmg = 22,
		melee_retry_delay = {
			1,
			1
		},
		range = HHRange(2000, 2000, 3000),
		FALLOFF = { HHFalloff(6, 100, 0.1, 0.9, 0.1, 0.15, 1, 0, 0, 0), HHFalloff(6, 500, 0.1, 0.85, 0.1, 0.15, 1, 0, 0, 0), HHFalloff(6, 1000, 0, 0.7, 0.1, 0.15, 1, 0, 0, 0), HHFalloff(4, 2000, 0, 0.5, 0.1, 0.15, 1, 0, 0, 0), HHFalloff(4, 3000, 0, 0.35, 0.1, 0.15, 1, 0, 1, 0), HHFalloff(0, 4000, 0, 0, 0.1, 0.15, 1, 0, 0, 0) }
	}
	presets.weapon.fbigod.is_rifle = {
		aim_delay = {
			0.6,
			0.6
		},
		focus_delay = 0.7,
		focus_dis = 500, --focus displacement punishment starts after 5m
		spread = 10,
		miss_dis = 0,
		RELOAD_SPEED = 1.8, --DW style.
		melee_speed = 0.75,
		melee_dmg = 22, --100 damage on melee
		melee_retry_delay = {
			1,
			1
		},
		tase_distance = 1500, --include tase parameters so that tasers can scale with difficulties better, since doing it the other way would keep reload speed, autofire rounds and other parameters unchanged
		aim_delay_tase = {
			0,
			0
		},
		tase_sphere_cast_radius = 30,
		range = HHRange(2000, 3000, 4000),
		autofire_rounds = { --yes.
			1,
			5
		},
		FALLOFF = { HHFalloff(7.5, 500, 0.2, 1, 0.2, 0.2, 0, 0, 0, 1), HHFalloff(7.5, 1000, 0, 0.8, 0.1, 0.2, 0, 0, 0, 1), HHFalloff(7.5, 2000, 0, 0.6, 0.25, 0.3, 0, 0, 0, 1), HHFalloff(6, 3000, 0, 0.4, 0.25, 0.35, 0, 0, 0, 1), HHFalloff(0, 4000, 0, 0, 0.25, 0.35, 1, 0, 0, 0) }
	}

	--commonly used presets for enemies replaced by existing presets
	presets.weapon.normal = deep_clone(presets.weapon.civil)
	presets.weapon.good = deep_clone(presets.weapon.civil)
	presets.weapon.expert = deep_clone(presets.weapon.civil)
	presets.weapon.deathwish = deep_clone(presets.weapon.complex)

	presets.weapon.gang_member = {
		is_pistol = {}
	}
	presets.weapon.gang_member.is_pistol.aim_delay = { 0.2, 0.3 }
	presets.weapon.gang_member.is_pistol.focus_delay = 1.2
	presets.weapon.gang_member.is_pistol.focus_dis = 200
	presets.weapon.gang_member.is_pistol.spread = 3
	presets.weapon.gang_member.is_pistol.miss_dis = 20
	presets.weapon.gang_member.is_pistol.RELOAD_SPEED = 1.5
	presets.weapon.gang_member.is_pistol.melee_speed = 2
	presets.weapon.gang_member.is_pistol.melee_dmg = 45
	presets.weapon.gang_member.is_pistol.melee_retry_delay = presets.weapon.normal.is_pistol.melee_retry_delay
	presets.weapon.gang_member.is_pistol.range = HHRange(3000, 4000, 6000)
	presets.weapon.gang_member.is_pistol.FALLOFF = { HHFalloff(6, 300, 1, 1, 0.25, 0.45, 0.1, 0.3, 4, 7), HHFalloff(1, 10000, 1, 1, 2, 3, 0.1, 0.3, 4, 7) }
	presets.weapon.gang_member.is_rifle = {
		aim_delay = {
			0.25,
			0.3
		},
		focus_delay = 1,
		focus_dis = 100,
		spread = 3,
		miss_dis = 10,
		RELOAD_SPEED = 1,
		melee_speed = 2,
		melee_dmg = 45,
		melee_retry_delay = presets.weapon.normal.is_rifle.melee_retry_delay,
		range = HHRange(3000, 4000, 6000),
		autofire_rounds = {1, 5},
		FALLOFF = { HHFalloff(3, 400, 1, 1, 0.3, 0.3, 0, 0, 0, 1), HHFalloff(3, 1000, 0.3, 0.9, 0.3, 0.9, 0, 0, 0, 1), HHFalloff(3, 2000, 0.2, 0.5, 0.6, 1, 0.25, 0.5, 0.25, 0), HHFalloff(3, 4000, 0, 0.25, 0.6, 1.2, 0.25, 0.5, 0.25, 0) }
	}
	presets.weapon.gang_member.is_sniper = {
		aim_delay = {
			0.35,
			1
		},
		focus_delay = 1.5,
		focus_dis = 200,
		spread = 1,
		miss_dis = 10,
		RELOAD_SPEED = 1,
		melee_speed = 2,
		melee_dmg = 45,
		melee_retry_delay = presets.weapon.normal.is_rifle.melee_retry_delay,
		range = HHRange(3000, 4000, 6000),
		FALLOFF = { HHFalloff(2.5, 500, 0, 1, 1, 1, 1, 0, 0, 0), HHFalloff(2.5, 1000, 0, 1, 1, 1.5, 1, 0, 0, 0), HHFalloff(2.5, 2500, 0, 1, 1.5, 2, 1, 0, 0, 0), HHFalloff(2.5, 4000, 0, 1, 2, 4, 1, 0, 0, 0), HHFalloff(2.5, 6000, 0, 1, 3, 6, 1, 0, 0, 0) }
	}
	presets.weapon.gang_member.is_lmg = {
		aim_delay = {
			0.35,
			1
		},
		focus_delay = 1,
		focus_dis = 200,
		spread = 3,
		miss_dis = 10,
		RELOAD_SPEED = 0.3,
		melee_speed = 2,
		melee_dmg = 45,
		melee_retry_delay = presets.weapon.normal.is_lmg.melee_retry_delay,
		range = HHRange(3000, 4000, 6000),
		autofire_rounds = {10, 30},
		spread_only = true,
		FALLOFF = { HHFalloff(4.2, 400, 60, 6, 2.5, 3.5, 0, 0, 0, 1), HHFalloff(4.2, 1000, 60, 6, 2.5, 3.5, 0, 0, 0, 1), HHFalloff(4.2, 2000, 60, 20, 2.5, 3.5, 0, 0, 0, 1), HHFalloff(4.2, 3000, 80, 35, 2.5, 3.5, 0, 0, 0, 1) }
	}
	presets.weapon.gang_member.is_shotgun_pump = {
		aim_delay = {
			0.25,
			0.3
		},
		focus_delay = 3,
		focus_dis = 100,
		spread = 3,
		miss_dis = 10,
		RELOAD_SPEED = 2,
		melee_speed = 2,
		melee_dmg = 45,
		melee_retry_delay = presets.weapon.normal.is_shotgun_pump.melee_retry_delay,
		range = HHRange(3000, 4000, 6000),
		FALLOFF = { HHFalloff(3, 1000, 0.5, 1, 0.75, 1, 1, 0, 0, 0), HHFalloff(1.5, 2000, 0, 1, 0.75, 1.5, 1, 0, 0, 0), HHFalloff(0.5, 3000, 0, 0.75, 2, 3, 1, 0, 0, 0) }
	}
	presets.weapon.gang_member.is_shotgun_mag = {
		aim_delay = {
			0.25,
			0.35
		},
		focus_delay = 1,
		focus_dis = 200,
		spread = 3,
		miss_dis = 10,
		RELOAD_SPEED = 1.6,
		melee_speed = 2,
		melee_dmg = 3,
		melee_retry_delay = presets.weapon.normal.is_shotgun_mag.melee_retry_delay,
		range = HHRange(3000, 4000, 6000),
		autofire_rounds = {
			1,
			3
		},
		FALLOFF = { HHFalloff(4.2, 400, 0.6, 1, 0.1, 0.1, 1, 1, 4, 6), HHFalloff(4.2, 800, 0, 1, 0.1, 0.1, 1, 1, 4, 5), HHFalloff(3.8, 1000, 0, 0.95, 0.1, 0.15, 1, 2, 4, 4), HHFalloff(2, 2000, 0, 0.6, 0.25, 0.45, 1, 4, 4, 1), HHFalloff(2, 3000, 0, 0.3, 0.4, 0.5, 4, 2, 1, 0) }
	}
	presets.weapon.gang_member.is_smg = presets.weapon.gang_member.is_rifle
	presets.weapon.gang_member.is_pistol = presets.weapon.gang_member.is_pistol
	presets.weapon.gang_member.is_revolver = presets.weapon.gang_member.is_pistol
	presets.weapon.gang_member.is_bullpup = presets.weapon.gang_member.is_rifle
	presets.weapon.gang_member.mac11 = presets.weapon.gang_member.is_smg
	presets.weapon.gang_member.rifle = deep_clone(presets.weapon.gang_member.is_pistol)
	presets.weapon.gang_member.rifle.autofire_rounds = nil
	presets.weapon.gang_member.rifle.FALLOFF = { HHFalloff(10, 300, 0.6, 1, 0.25, 0.3, 1, 0, 0, 0), HHFalloff(10, 1000, 0.4, 1, 0.3, 0.5, 1, 0, 0, 0), HHFalloff(10, 2000, 0, 1, 0.5, 0.8, 1, 0, 0, 0), HHFalloff(10, 3000, 0, 0.6, 0.6, 1, 1, 0, 0, 0) }
	presets.weapon.gang_member.akimbo_pistol = presets.weapon.gang_member.is_pistol

	presets.enemy_chatter = {
		no_chatter = {},
		security = {
			aggressive = true,
			go_go = true,
			announce_criminal = true,
			suppress = true
		},
		cop = {
			entry = true,
			idlechatter = true,
			push = true,
			ready = true,
			retreat = true,
			smoke = true,
			flash_grenade = true,
			aggressive = true,
			go_go = true,
			contact = true,
			suppress = true
		},
		swat = {
			entry = true,
			idlechatter = true,
			push = true,
			clear = true,
			ready = true,
			contact = true,
			suppress = true,
			smoke = true,
			flash_grenade = true,
			retreat = true,
			go_go = true,
			aggressive = true,
			follow_me = true
		},
		shield = {
			idlechatter = true,
			push = true,
			clear = true,
			ready = true,
			contact = true,
			suppress = true,
			smoke = true,
			flash_grenade = true,
			retreat = true,
			go_go = true,
			aggressive = true,
			follow_me = true
        },
		bulldozer = {
			tankgeneral = true,
			contact = true,
			aggressive = true,
			approachingspecial = true

		},
		taser = {
			tasergeneral = true,
			contact = true,
			aggressive = true,
			retreat = true,
			approachingspecial = true
		},
		medic = {
			imamedicionlyhaveliketwovoicelineshaha = true
		},
		spooc = {
			cloakergeneral = true,
			cloakercontact = true,
			go_go = true, --only used for russian cloaker
			cloakeravoidance = true --only used for russian cloaker
		}
	}

	return presets
end

function CharacterTweakData:_set_characters_weapon_preset(preset)
	local presets = self.presets

	for i = 1, #self._enemy_list do
		local name = self._enemy_list[i]

		self[name].weapon = presets.weapon[preset]
	end

	self.sniper.weapon = presets.weapon.rhythmsniper
	self.heavy_swat_sniper.weapon = presets.weapon.rhythmsniper
	self.armored_sniper.weapon = presets.weapon.rhythmsniper
	self.tank_ftsu.weapon = presets.weapon.rhythmsniper
end

function CharacterTweakData:_set_characters_crumble_chance(light_swat_chance, heavy_swat_chance, common_chance)
	local heavy_units ={ "fbi_heavy_swat", "heavy_swat" }

	local light_units = { "swat", "fbi_swat", "city_swat" }

	local punks_units = {
		"security",
		"security_undominatable",
		"security_mex",
		"security_mex_no_pager",
		"security_undominatable",
		"mute_security_undominatable",
		"gensec",
		"cop",
		"cop_moss",
		"cop_scared",
		"gangster",
		"bolivian",
		"triad",
		"mobster",
		"biker",
		"mobster",
		"bolivian_indoors",
		"bolivian_indoors_mex"
	}

	for _, cname in ipairs(punks_units) do
		self[cname].crumble_chance = common_chance
		self[cname].allow_pass_out = true
		self[cname].damage.fire_damage_mul = 18
	end

	if self.security_no_pager then
		self.security_no_pager.crumble_chance = common_chance
		self.security_no_pager.allow_pass_out = true
		self.security_no_pager.damage.fire_damage_mul = 18
	end

	for _, lname in ipairs(light_units) do
		self[lname].crumble_chance = light_swat_chance
		self[lname].allow_pass_out = true
		self[lname].damage.fire_damage_mul = 12
	end

	for _, hname in ipairs(heavy_units) do
		self[hname].crumble_chance = heavy_swat_chance
		self[hname].damage.fire_damage_mul = 6
	end
end

function CharacterTweakData:_init_tank(presets) --TODO: Nothing yet. Note: Can't make this a post hook due to the melee glitch fix, figure something out later to fix it WITH posthooks if possible.
	self.tank = deep_clone(presets.base)
	self.tank.tags = { "law", "takedown", "tank", "special", "frontliner", "protected" }
	self.tank.experience = {}
	self.tank.damage.tased_response = {
		light = {
			down_time = 0,
			tased_time = 1
		},
		heavy = {
			down_time = 0,
			tased_time = 2
		}
	}
	self.tank.weapon = deep_clone(presets.weapon.civil)
	self.tank.detection = presets.detection.enemymook
	self.tank.HEALTH_INIT = 502.5
	self.tank.headshot_dmg_mul = 64
	self.tank.damage.explosion_damage_mul = 1.75 --nngh.
	self.tank.damage.fire_damage_mul = 2
	self.tank.move_speed = presets.move_speed.slow_consistency
	self.tank.allowed_stances = {
		cbt = true
	}
	self.tank.allowed_poses = {
		stand = true
	}
	self.tank.cannot_throw_grenades = true
	self.tank.crouch_move = false
	self.tank.shooting_death = false
	self.tank.no_run_start = true
	self.tank.no_run_stop = true
	self.tank.no_retreat = nil
	self.tank.no_arrest = true
	self.tank.surrender = nil
	self.tank.always_face_enemy = true
	self.tank.ecm_vulnerability = 0 --no more dozer weirdness due to ecms, also a buff I guess.
	self.tank.ecm_hurts = {
		ears = {
			max_duration = 3,
			min_duration = 1
		}
	}
	self.tank.weapon_voice = "3"
	self.tank.experience.cable_tie = "tie_swat"
	self.tank.access = "tank"
	self.tank.speech_prefix_p1 = self._prefix_data_p1.bulldozer()
	self.tank.speech_prefix_p2 = nil
	self.tank.speech_prefix_count = nil
	self.tank.spawn_sound_event = self._prefix_data_p1.bulldozer() .. "_entrance" --BULLDOZER, COMING THROUGH!!!
	self.tank.priority_shout = "f30"
	self.tank.silent_priority_shout = "f37"
	self.tank.rescue_hostages = false
	self.tank.deathguard = true
	self.tank.melee_weapon = "fists"
	self.tank.melee_weapon_dmg_multiplier = 2.5
	self.tank.critical_hits = nil
	self.tank.die_sound_event = "bdz_x02a_any_3p"
	self.tank.damage.doom_hurt_type = "doomzer"
	self.tank.damage.hurt_severity = presets.hurt_severities.no_hurts_no_tase
	self.tank.chatter = presets.enemy_chatter.bulldozer
	self.tank.announce_incomming = "incomming_tank"
	self.tank.steal_loot = nil
	self.tank.calls_in = nil
	self.tank.use_animation_on_fire_damage = false
	self.tank.flammable = true
	self.tank.can_be_tased = false
	self.tank.immune_to_knock_down = true
	self.tank.immune_to_concussion = true

	self.tank_hw = deep_clone(self.tank)
	self.tank_hw.tags = { "law", "takedown", "tank", "special", "ohfuck" }
	self.tank_hw.move_speed = presets.move_speed.mini_consistency --lol stop
	self.tank_hw.HEALTH_INIT = 100 --3200 on top difficulty, encourage teamfire against these guys since they're gonna be on the halloween maps
	self.tank_hw.headshot_dmg_mul = 1
	self.tank_hw.ignore_headshot = true
	self.tank_hw.damage.explosion_damage_mul = 1
	self.tank_hw.damage.fire_damage_mul = 1
	self.tank_hw.use_animation_on_fire_damage = false
	self.tank_hw.flammable = true
	self.tank_hw.can_be_tased = false
	self.tank_hw.melee_weapon = "helloween"

	self.tank_medic = deep_clone(self.tank)
	self.tank_medic.move_speed = presets.move_speed.simple_consistency --tiny bit faster, their gun is lighter.
	self.tank_medic.weapon = deep_clone(presets.weapon.civil)
	self.tank_medic.spawn_sound_event = self._prefix_data_p1.bulldozer() .. "_entrance_elite"
	self.tank_medic.tags = { "law", "backliner", "tank", "medic", "special", "protected" }

	self.tank_mini = deep_clone(self.tank)
	self.tank_mini.tags = {
		"law",
		"frontliner",
		"takedown",
		"tank",
		"protected",
		"special",
		"ohfuck",
		"no_run"
	}
	self.tank_mini.move_speed = presets.move_speed.mini_consistency --New movement presets.
	self.tank_mini.spawn_sound_event = self._prefix_data_p1.bulldozer() .. "_entrance_elite"
	self.tank_mini.always_face_enemy = true
	self.tank_mini.damage.fire_damage_mul = 1
	self.tank_mini.melee_weapon = nil
	self.tank_mini.melee_weapon_dmg_multiplier = nil

	self.tank_ftsu = deep_clone(self.tank) --and just like that, ive turned a meme into a real thing
	self.tank_ftsu.tags = { "law", "tank", "special", "no_run" }
	self.tank_ftsu.weapon = presets.weapon.rhythmsniper
	self.tank_ftsu.move_speed = presets.move_speed.mini_consistency
	self.tank_ftsu.spawn_sound_event = self._prefix_data_p1.bulldozer() .. "_entrance_elite"
	self.tank_ftsu.always_face_enemy = true

	self.trolliam_epicson = deep_clone(self.tank) --trolliam
	self.trolliam_epicson.tags = { "law", "tank", "spooc", "special" }
	self.trolliam_epicson.HEALTH_INIT = 999999
	self.trolliam_epicson.move_speed = presets.move_speed.lightning_constant
	self.trolliam_epicson.spawn_sound_event = nil
	self.trolliam_epicson.always_face_enemy = true
	self.trolliam_epicson.access = "spooc"
	self.trolliam_epicson.melee_weapon = "baton"
	self.trolliam_epicson.use_animation_on_fire_damage = false
	self.trolliam_epicson.flammable = false
	self.trolliam_epicson.dodge = presets.dodge.ninja
	self.trolliam_epicson.chatter = presets.enemy_chatter.spooc
	self.trolliam_epicson.spooc_attack_timeout = { 0.35, 0.35 }
	self.trolliam_epicson.spooc_attack_beating_time = { 3, 3 }
	self.trolliam_epicson.spooc_sound_events = {
		detect_stop = "cloaker_detect_stop",
		detect = "cloaker_detect_mono"
	}

	table.insert(self._enemy_list, "tank_ftsu")
	table.insert(self._enemy_list, "trolliam_epicson")
end

function CharacterTweakData:_init_spooc(presets) --Can't make this into a post hook, dodge with grenades gets re-enabled if I do, which isn't good for anybody, destroys framerates and doesn't let him use ninja_complex dodges.
	self.spooc = deep_clone(presets.base)
	self.spooc.tags = { "law", "spooc", "special", "backliner", "takedown" }
	self.spooc.experience = {}
	self.spooc.weapon = deep_clone(presets.weapon.civil)
	self.spooc.detection = presets.detection.enemyspooc
	self.spooc.HEALTH_INIT = 8
	self.spooc.headshot_dmg_mul = 7
	self.spooc.damage.fire_damage_mul = 8
	self.spooc.move_speed = presets.move_speed.lightning_constant
	self.spooc.no_retreat = nil
	self.spooc.no_arrest = true
	self.spooc.always_face_enemy = true
	self.spooc.damage.doom_hurt_type = "doom"
	self.spooc.damage.hurt_severity = presets.hurt_severities.specialenemy
	self.spooc.surrender_break_time = { 4, 6 }
	self.spooc.damage.no_suppression_crouch = true
	self.spooc.suppression = presets.suppression.stalwart_nil
	self.spooc.no_fumbling = true
	self.spooc.no_suppression_reaction = true
	self.spooc.surrender = presets.surrender.special
	self.spooc.priority_shout = "f33"
	self.spooc.silent_priority_shout = "f37"
	--self.spooc.priority_shout_max_dis = 700
	self.spooc.rescue_hostages = false
	self.spooc.spooc_attack_timeout = { 0.35, 0.35 }
	self.spooc.spooc_attack_beating_time = { 3, 3 }
	self.spooc.spooc_strike_anim_speed = 1.75
	self.spooc.spooc_attack_use_smoke_chance = 0 --lol stop
	self.spooc.play_spooc_noise = true
	self.spooc.weapon_voice = "3"
	self.spooc.experience.cable_tie = "tie_swat"
	self.spooc.speech_prefix_p1 = self._prefix_data_p1.cloaker()
	self.spooc.speech_prefix_p2 = nil
	self.spooc.speech_prefix_count = nil
	self.spooc.access = "spooc"
	self.spooc.melee_weapon = "baton"
	self.spooc.use_animation_on_fire_damage = true
	self.spooc.flammable = true
	self.spooc.dodge = presets.dodge.ninja
	self.spooc.chatter = presets.enemy_chatter.spooc
	self.spooc.steal_loot = nil
	self.spooc.spawn_sound_event = "cloaker_presence_loop"
	self.spooc.die_sound_event = "cloaker_presence_stop"
	self.spooc.spooc_sound_events = {
		detect_stop = "cloaker_detect_stop",
		detect = "cloaker_detect_mono"
	}
	self.spooc.special_deaths = {
		melee = {
			[("head"):id():key()] = {
				sequence = "dismember_head",
				melee_weapon_id = "sandsteel",
				character_name = "dragon",
				sound_effect = "split_gen_head"
			},
			[("body"):id():key()] = {
				sequence = "dismember_body_top",
				melee_weapon_id = "sandsteel",
				character_name = "dragon",
				sound_effect = "split_gen_body"
			}
		}
	}
	self.spooc_heavy = deep_clone(self.spooc)
	self.spooc_heavy.special_deaths = nil
	self.spooc.non_lethal_kick_damage = 15
	self.spooc.non_lethal_kick_push = 600
	self.spooc.non_lethal_kick_damage_effect = 15
	table.insert(self._enemy_list, "spooc_heavy")
end

Hooks:PostHook(CharacterTweakData, "_init_shadow_spooc", "fraypost_s_spooc", function(self, presets)
	self.shadow_spooc = deep_clone(presets.base)
	self.shadow_spooc.tags = { "law", "takedown" }
	self.shadow_spooc.experience = {}
	self.shadow_spooc.weapon = deep_clone(presets.weapon.fbigod)
	self.shadow_spooc.detection = presets.detection.enemymook
	self.shadow_spooc.HEALTH_INIT = 10
	self.shadow_spooc.headshot_dmg_mul = 8
	self.shadow_spooc.move_speed = presets.move_speed.lightning_constant
	self.shadow_spooc.spooc_vanish = true
	self.shadow_spooc.no_retreat = true
	self.shadow_spooc.no_arrest = true
	self.shadow_spooc.no_fumbling = true
	self.shadow_spooc.no_suppression_reaction = true
	self.shadow_spooc.damage.doom_hurt_type = "doom"
	self.shadow_spooc.damage.hurt_severity = presets.hurt_severities.specialenemy
	self.shadow_spooc.surrender_break_time = { 4, 6 }
	self.shadow_spooc.suppression = nil
	self.shadow_spooc.surrender = nil
	self.shadow_spooc.silent_priority_shout = "f37"
	self.shadow_spooc.priority_shout_max_dis = 700
	self.shadow_spooc.rescue_hostages = false
	self.shadow_spooc.spooc_attack_timeout = { 0.35, 0.35 }
	self.shadow_spooc.spooc_attack_beating_time = { 0.35, 0.35 }
	self.shadow_spooc.spooc_attack_use_smoke_chance = 0
	self.shadow_spooc.weapon_voice = "3"
	self.shadow_spooc.experience.cable_tie = "tie_swat"
	self.shadow_spooc.speech_prefix_p1 = "uno_clk"
	self.shadow_spooc.speech_prefix_p2 = nil
	self.shadow_spooc.speech_prefix_count = nil
	self.shadow_spooc.access = "spooc"
	self.shadow_spooc.use_radio = nil
	self.shadow_spooc.use_animation_on_fire_damage = nil
	self.shadow_spooc.flammable = true
	self.shadow_spooc.dodge = presets.dodge.ninja_complex
	self.shadow_spooc.chatter = presets.enemy_chatter.no_chatter
	self.shadow_spooc.do_not_drop_ammo = nil
	self.shadow_spooc.steal_loot = nil
	self.shadow_spooc.spawn_sound_event = "uno_cloaker_presence_loop"
	self.shadow_spooc.die_sound_event = "uno_cloaker_presence_stop"
	self.shadow_spooc.spooc_sound_events = {
		detect_stop = "uno_cloaker_detect_stop",
		taunt_during_assault = "",
		taunt_after_assault = "",
		detect = "uno_cloaker_detect"
	}
	self.shadow_swat = deep_clone(self.shadow_spooc)
	self.shadow_swat.health = 5
	self.shadow_swat.headshot_dmg_mul = 4
	self.shadow_swat.spawn_sound_event = nil
	self.shadow_swat.die_sound_event = nil
	self.shadow_swat.move_speed = presets.move_speed.anarchy_consistency

	self.shadow_taser = deep_clone(self.shadow_swat)
	self.shadow_taser.tags = { "taser" }
	self.shadow_taser.HEALTH_INIT = 20
	self.shadow_taser.headshot_dmg_mul = 2

	table.insert(self._enemy_list, "shadow_swat")
	table.insert(self._enemy_list, "shadow_taser")
end)

Hooks:PostHook(CharacterTweakData, "_init_shield", "fraypost_shield", function(self, presets) --TODO: Nothing yet.
	self.shield = deep_clone(presets.base)
	self.shield.tags = { "law", "shield", "special", "frontliner", "dense" }
	self.shield.experience = {}
	self.shield.weapon = presets.weapon.simple
	self.shield.detection = presets.detection.enemymook
	self.shield.damage.hurt_severity = presets.hurt_severities.no_hurts_no_tase
	self.shield.HEALTH_INIT = 6
	self.shield.headshot_dmg_mul = 6
	self.shield.speed_mul = 0.85
	self.shield.allowed_stances = {
		cbt = true
	}
	self.shield.allowed_poses = {
		crouch = true
	}
	self.shield.cannot_throw_grenades = true
	self.shield.always_face_enemy = true
	self.shield.move_speed = presets.move_speed.simple_consistency
	self.shield.no_run_start = true
	self.shield.no_run_stop = true
	self.shield.no_retreat = nil
	self.shield.no_arrest = true
	self.shield.no_fumbling = true
	self.shield.no_suppression_reaction = true
	self.shield.surrender = nil
	self.shield.priority_shout = "f31"
	self.shield.rescue_hostages = false
	self.shield.deathguard = true
	self.shield.no_equip_anim = true
	self.shield.damage.explosion_damage_mul = 0.8
	self.shield.damage.fire_damage_mul = 1
	self.shield.calls_in = nil
	self.shield.ignore_medic_revive_animation = true
	self.shield.damage.shield_knocked = true
	self.shield.use_animation_on_fire_damage = false
	self.shield.flammable = true
	self.shield.speech_prefix_p1 = self._prefix_data_p1.heavy_swat()
	self.shield.speech_prefix_p2 = self.shield.speech_prefix_p1 == "l" and "d" or self._speech_prefix_p2
	self.shield.speech_prefix_count = self.shield.speech_prefix_p2 == "d" and 5 or 4
	self.shield.spawn_sound_event = "shield_identification" --important
	self.shield.access = "shield"
	self.shield.chatter = presets.enemy_chatter.shield
	self.shield.announce_incomming = "incomming_shield"
	self.shield.steal_loot = nil

end)

Hooks:PostHook(CharacterTweakData, "_init_medic", "fraypost_medic", function(self, presets) --TODO: Nothing right now.
	self.medic.tags = { "law", "medic", "backliner", "special", "dense" }
	self.medic.weapon = presets.weapon.civil
	self.medic.detection = presets.detection.enemymook
	self.medic.HEALTH_INIT = 8
	self.medic.headshot_dmg_mul = 6
	self.medic.damage.doom_hurt_type = "doom"
	self.medic.damage.hurt_severity = presets.hurt_severities.specialenemy
	self.medic.damage.no_suppression_crouch = true
	self.medic.suppression = presets.suppression.stalwart_nil
	self.medic.no_fumbling = true
	self.medic.no_suppression_reaction = true
	self.medic.no_retreat = nil
	self.medic.surrender = presets.surrender.special
	self.medic.move_speed = presets.move_speed.simple_consistency
	self.medic.surrender_break_time = { 7, 12 }
	self.medic.ecm_vulnerability = 0
	self.medic.ecm_hurts = {
		ears = {
			max_duration = 10,
			min_duration = 8
		}
	}
	self.medic.damage.fire_damage_mul = 8
	self.medic.chatter = presets.enemy_chatter.medic
	self.medic.experience.cable_tie = "tie_swat"
	self.medic.speech_prefix_p1 = self._prefix_data_p1.medic()
	self.medic.speech_prefix_p2 = nil
	self.medic.speech_prefix_count = nil
	self.medic.spawn_sound_event = self._prefix_data_p1.medic() .. "_entrance"
	self.medic.silent_priority_shout = "f37"
	self.medic.access = "swat"
	self.medic.dodge = presets.dodge.athletic
	self.medic.melee_weapon = "knife_1"
	self.medic.deathguard = true
	self.medic.no_arrest = true
end)

Hooks:PostHook(CharacterTweakData, "_init_taser", "fraypost_taser", function(self, presets) --TODO: Nothing right now.
	self.taser.tags = { "law", "taser", "special", "takedown" }
	self.taser.weapon = presets.weapon.simple
	self.taser.detection = presets.detection.enemymook
	self.taser.HEALTH_INIT = 20
	self.taser.headshot_dmg_mul = 3
	self.taser.speed_mul = 0.9
	self.taser.damage.doom_hurt_type = "doom"
	self.taser.damage.fire_damage_mul = 0.25
	self.taser.damage.hurt_severity = presets.hurt_severities.specialenemy
	self.taser.move_speed = presets.move_speed.simple_consistency
	self.taser.suppression = presets.suppression.stalwart_nil
	self.taser.no_fumbling = true
	self.taser.no_suppression_reaction = true
	self.taser.no_retreat = nil
	self.taser.no_arrest = true
	self.taser.surrender = presets.surrender.special
	self.taser.ecm_vulnerability = 0
	self.taser.ecm_hurts = {
		ears = {
			max_duration = 3,
			min_duration = 1
		}
	}
	self.taser.surrender_break_time = { 4, 6 }
	self.taser.suppression = nil
	self.taser.speech_prefix_p1 = self._prefix_data_p1.taser()
	self.taser.speech_prefix_p2 = nil
	self.taser.speech_prefix_count = nil
	self.taser.spawn_sound_event = self._prefix_data_p1.taser() .. "_entrance"
	self.taser.access = "taser"
	self.taser.special_deaths.melee = {
		[("head"):id():key()] = {
			melee_weapon_id = "fists",
			character_name = "dragan",
			sequence = "kill_tazer_headshot"
		}
	}
	self.taser.melee_weapon = "fists"
	self.taser.chatter = presets.enemy_chatter.taser
	self.taser.dodge = presets.dodge.athletic
	self.taser.priority_shout = "f32"
	self.taser.rescue_hostages = false
	self.taser.deathguard = true
	self.taser.announce_incomming = "incomming_taser"
	self.taser.steal_loot = nil
	self.taser.die_sound_event = "tsr_x02a_any_3p"

end)

Hooks:PostHook(CharacterTweakData, "_init_swat", "fraypost_swat", function(self, presets)
	self.swat.tags = { "law", "dense" }
	self.swat.weapon = presets.weapon.simple
	self.swat.detection = presets.detection.enemymook
	self.swat.HEALTH_INIT = 6
	self.swat.headshot_dmg_mul = 3
	self.swat.ecm_vulnerability = 1
	self.swat.ecm_hurts = {
		ears = {
			max_duration = 2,
			min_duration = 2
		}
	}
	self.swat.move_speed = presets.move_speed.simple_consistency
	self.swat.damage.doom_hurt_type = "light"
	self.swat.damage.hurt_severity = presets.hurt_severities.hordemook
	self.swat.suppression = presets.suppression.hard_def
	self.swat.surrender = presets.surrender.easy
	self.swat.experience.cable_tie = "tie_swat"
	self.swat.speech_prefix_p1 = self._prefix_data_p1.swat()
	self.swat.speech_prefix_p2 = self._speech_prefix_p2
	self.swat.speech_prefix_count = 4
	self.swat.access = "swat"
	self.swat.dodge = presets.dodge.athletic
	self.swat.no_arrest = true
	self.swat.no_retreat = nil
	self.swat.chatter = presets.enemy_chatter.swat
	self.swat.melee_weapon_dmg_multiplier = 1
	self.swat.steal_loot = true
	self.swat.silent_priority_shout = "f37"

end)

Hooks:PostHook(CharacterTweakData, "_init_fbi", "fraypost_fbi", function(self, presets)
	self.fbi = deep_clone(presets.base)
	self.fbi.tags = { "law", "fbi", "takedown", "dense" }
	self.fbi.experience = {}
	self.fbi.weapon = presets.weapon.fbigod
	self.fbi.detection = presets.detection.enemymook
	self.fbi.no_fumbling = true
	self.fbi.no_suppression_reaction = true
	self.fbi.no_retreat = nil
	self.fbi.HEALTH_INIT = 8
	self.fbi.headshot_dmg_mul = 9
	self.fbi.move_speed = presets.move_speed.simple_consistency
	self.fbi.damage.no_suppression_crouch = true
	self.fbi.suppression = presets.suppression.stalwart_nil
	self.fbi.surrender = presets.surrender.hard
	self.fbi.damage.doom_hurt_type = "doom"
	self.fbi.damage.hurt_severity = presets.hurt_severities.specialenemy
	self.fbi.ecm_vulnerability = 0
	self.fbi.ecm_hurts = {
		ears = {
			max_duration = 3,
			min_duration = 1
		}
	}
	self.fbi.weapon_voice = "2"
	self.fbi.experience.cable_tie = "tie_swat"
	self.fbi.speech_prefix_p1 = self._prefix_data_p1.cop()
	self.fbi.speech_prefix_p2 = self._speech_prefix_p2
	self.fbi.speech_prefix_count = 4
	self.fbi.silent_priority_shout = "f37"
	self.fbi.melee_weapon = "fists"
	self.fbi.dodge = presets.dodge.athletic
	self.fbi.deathguard = true
	self.fbi.no_arrest = nil
	self.fbi.chatter = presets.enemy_chatter.swat
	self.fbi.steal_loot = true
	if level == "kosugi" or level == "kosugi_hh" then
		-- log("wow")
		self.fbi.access = "security"
	else
		self.fbi.access = "spooc"
	end
	self.fbi_pager = deep_clone(self.fbi)
	local level = Global.level_data and Global.level_data.level_id
	if level == "kosugi" or level == "kosugi_hh" then
		-- log("wow")
		self.fbi_pager.access = "security"
	else
		self.fbi_pager.access = "spooc"
	end
	self.fbi_pager.has_alarm_pager = true
	table.insert(self._enemy_list, "fbi_pager")
	self.fbi_xc45 = deep_clone(self.fbi)
	self.fbi_xc45.damage.hurt_severity = presets.hurt_severities.no_hurts
	self.fbi_xc45.surrender = presets.surrender.hard
	self.fbi_xc45.allowed_stances = {
		cbt = true
	}
	self.fbi_xc45.use_animation_on_fire_damage = false
	self.fbi_xc45.melee_weapon = nil
	table.insert(self._enemy_list, "fbi_xc45")
	self.gangster_ninja = deep_clone(self.fbi)
	self.gangster_ninja.HEALTH_INIT = 20 --slightly more health. probably not necessary but screw you.
	self.gangster_ninja.tags = nil
    self.gangster_ninja.calls_in = false
	self.gangster_ninja.no_retreat = true
	self.gangster_ninja.surrender = nil
	self.gangster_ninja.ecm_vulnerability = 0 --why would gangsters have headsets lol
	self.gangster_ninja.access = "gangster"
	local job = Global.level_data and Global.level_data.level_id
	if job == "nightclub" or job == "short2_stage1" or job == "jolly" or job == "spa" then
		self.gangster_ninja.speech_prefix_p1 = "rt"
		self.gangster_ninja.speech_prefix_p2 = nil
		self.gangster_ninja.speech_prefix_count = 2
	elseif job == "alex_2" then
		self.gangster_ninja.speech_prefix_p1 = "ict"
		self.gangster_ninja.speech_prefix_p2 = nil
		self.gangster_ninja.speech_prefix_count = 2
	elseif job == "welcome_to_the_jungle_1" then
		self.gangster_ninja.speech_prefix_p1 = "bik"
		self.gangster_ninja.speech_prefix_p2 = nil
		self.gangster_ninja.speech_prefix_count = 2
	else
		self.gangster_ninja.speech_prefix_p1 = "lt"
		self.gangster_ninja.speech_prefix_p2 = nil
		self.gangster_ninja.speech_prefix_count = 2
	end
	self.gangster_ninja.challenges = {type = "gangster"}
	table.insert(self._enemy_list, "gangster_ninja")

	self.fbi_girl = deep_clone(self.fbi) --replaces cop_female, these spawns are extremely scripted and semi-rare so it feels right to make them all ninjas
	self.fbi_girl.speech_prefix_p1 = "fl"
	self.fbi_girl.speech_prefix_p2 = "n"
	self.fbi_girl.speech_prefix_count = 1
	table.insert(self._enemy_list, "fbi_girl")

	self.cop_female = deep_clone(self.fbi_girl) --re-clone, therefore, preserving unit functionality
end)

Hooks:PostHook(CharacterTweakData, "_init_heavy_swat", "fraypost_hswat", function(self, presets) --TODO: Nothing right now.
	self.heavy_swat = deep_clone(presets.base)
	self.heavy_swat.tags = { "law", "dense" }
	self.heavy_swat.experience = {}
	self.heavy_swat.weapon = presets.weapon.simple
	self.heavy_swat.detection = presets.detection.enemymook
	self.heavy_swat.HEALTH_INIT = 10
	self.heavy_swat.speed_mul = 0.9
	self.heavy_swat.headshot_dmg_mul = 3
	self.heavy_swat.ecm_vulnerability = 1
	self.heavy_swat.resist_death = {
		bullet = true
	}
	self.heavy_swat.ecm_hurts = {
		ears = {
			max_duration = 2,
			min_duration = 2
		}
	}
	self.heavy_swat.damage.explosion_damage_mul = 1
	self.heavy_swat.damage.doom_hurt_type = "heavy"
	self.heavy_swat.move_speed = presets.move_speed.simple_consistency
	self.heavy_swat.damage.hurt_severity = presets.hurt_severities.heavyhordemook
	self.heavy_swat.DAMAGE_CLAMP_FIREDOT = 10
	self.heavy_swat.suppression = presets.suppression.hard_agg
	self.heavy_swat.surrender = presets.surrender.normal
	self.heavy_swat.experience.cable_tie = "tie_swat"
	self.heavy_swat.speech_prefix_p1 = self._prefix_data_p1.heavy_swat()
	self.heavy_swat.speech_prefix_p2 = self._speech_prefix_p2
	self.heavy_swat.speech_prefix_count = 4
	self.heavy_swat.melee_weapon = "fists"
	local level = Global.level_data and Global.level_data.level_id
	if level == "kosugi" or level == "kosugi_hh" then
		-- log("damn daniel")
		self.heavy_swat.access = "security"
	else
		self.heavy_swat.access = "swat"
	end
	self.heavy_swat.dodge = presets.dodge.heavy
	self.heavy_swat.no_arrest = true
	self.heavy_swat.no_retreat = nil
	self.heavy_swat.chatter = presets.enemy_chatter.swat
	self.heavy_swat.steal_loot = true
	self.heavy_swat.silent_priority_shout = "f37"

end)

-- Marshal PostHooks removed: units disabled via groupaitweakdata


Hooks:PostHook(CharacterTweakData, "_init_fbi_swat", "fraypost_fswat", function(self, presets)
	self.fbi_swat.tags = { "law", "dense" }
	self.fbi_swat.weapon = presets.weapon.civil
	self.fbi_swat.detection = presets.detection.enemymook
	self.fbi_swat.HEALTH_INIT = 6
	self.fbi_swat.headshot_dmg_mul = 3
	self.fbi_swat.ecm_vulnerability = 1
	self.fbi_swat.ecm_hurts = {
		ears = {
			max_duration = 2,
			min_duration = 2
		}
	}
	self.fbi_swat.move_speed = presets.move_speed.simple_consistency
	self.fbi_swat.suppression = presets.suppression.hard_def
	self.fbi_swat.surrender = presets.surrender.easy
	self.fbi_swat.damage.doom_hurt_type = "light"
	self.fbi_swat.damage.hurt_severity = presets.hurt_severities.hordemook
	self.fbi_swat.speech_prefix_p1 = self._prefix_data_p1.swat()
	self.fbi_swat.speech_prefix_p2 = self._speech_prefix_p2
	self.fbi_swat.speech_prefix_count = 4
	self.fbi_swat.dodge = presets.dodge.athletic
	self.fbi_swat.no_arrest = true
	self.fbi_swat.no_retreat = nil
	self.fbi_swat.chatter = presets.enemy_chatter.swat
	self.fbi_swat.melee_weapon = "knife_1"
	self.fbi_swat.steal_loot = true
	self.fbi_swat.silent_priority_shout = "f37"

	local level = Global.level_data and Global.level_data.level_id
	if level == "kosugi" or level == "kosugi_hh" then
		-- log("damn daniel")
		self.fbi_swat.access = "security"
	else
		-- log("wew")
		self.fbi_swat.access = "swat"
	end

	self.armored_swat = deep_clone(self.fbi_swat)
	self.armored_swat.tags = { "law", "protected_reverse", "dense" }
	self.armored_swat.HEALTH_INIT = 200
	self.armored_swat.headshot_dmg_mul = 12
	self.armored_swat.move_speed = presets.move_speed.simple_consistency
	self.armored_swat.damage.doom_hurt_type = "doom"
	self.armored_swat.damage.hurt_severity = presets.hurt_severities.heavyhordemook
	self.armored_swat.surrender = presets.surrender.hard
	table.insert(self._enemy_list, "armored_swat")

end)

Hooks:PostHook(CharacterTweakData, "_init_fbi_heavy_swat", "fraypost_fhswat", function(self, presets) --TODO: Nothing right now.
	self.fbi_heavy_swat.tags = { "law", "dense" }
	self.fbi_heavy_swat.weapon = presets.weapon.civil
	self.fbi_heavy_swat.detection = presets.detection.enemymook
	self.fbi_heavy_swat.HEALTH_INIT = 10
	self.fbi_heavy_swat.speed_mul = 0.9
	self.fbi_heavy_swat.headshot_dmg_mul = 3
	self.fbi_heavy_swat.ecm_vulnerability = 1
	self.fbi_heavy_swat.resist_death = {
		bullet = true
	}
	self.fbi_heavy_swat.ecm_hurts = {
		ears = {
			max_duration = 2,
			min_duration = 2
		}
	}
	self.fbi_heavy_swat.damage.explosion_damage_mul = 1
	self.fbi_heavy_swat.move_speed = presets.move_speed.simple_consistency
	self.fbi_heavy_swat.damage.doom_hurt_type = "heavy"
	self.fbi_heavy_swat.damage.hurt_severity = presets.hurt_severities.heavyhordemook
	self.fbi_heavy_swat.DAMAGE_CLAMP_FIREDOT = 10
	self.fbi_heavy_swat.suppression = presets.suppression.hard_agg
	self.fbi_heavy_swat.surrender = presets.surrender.normal
	self.fbi_heavy_swat.speech_prefix_p1 = self._prefix_data_p1.heavy_swat()
	self.fbi_heavy_swat.speech_prefix_p2 = self._speech_prefix_p2
	self.fbi_heavy_swat.speech_prefix_count = 4
	local level = Global.level_data and Global.level_data.level_id
	if level == "kosugi" or level == "kosugi_hh" then
		-- log("damn daniel")
		self.fbi_heavy_swat.access = "security"
	else
		self.fbi_heavy_swat.access = "swat"
	end
	self.fbi_heavy_swat.access = "swat"
	self.fbi_heavy_swat.dodge = presets.dodge.heavy
	self.fbi_heavy_swat.no_arrest = true
	self.fbi_heavy_swat.no_retreat = nil
	self.fbi_heavy_swat.chatter = presets.enemy_chatter.swat
	self.fbi_heavy_swat.melee_weapon = "knife_1"
	self.fbi_heavy_swat.steal_loot = true
	self.fbi_heavy_swat.silent_priority_shout = "f37"

end)

Hooks:PostHook(CharacterTweakData, "_init_city_swat", "fraypost_cswat", function(self, presets)
	self.city_swat.tags = { "law", "dense" }
	self.city_swat.weapon = presets.weapon.civil
	self.city_swat.detection = presets.detection.enemymook
	self.city_swat.HEALTH_INIT = 6
	self.city_swat.no_arrest = true
	self.city_swat.headshot_dmg_mul = 3
	self.city_swat.ecm_vulnerability = 1
	self.city_swat.ecm_hurts = {
		ears = {
			max_duration = 2,
			min_duration = 2
		}
	}
	self.city_swat.move_speed = presets.move_speed.simple_consistency
	self.city_swat.damage.hurt_severity = presets.hurt_severities.hordemook
	self.city_swat.suppression = presets.suppression.hard_def
	self.city_swat.surrender = presets.surrender.easy
	self.city_swat.silent_priority_shout = "f37"
	self.city_swat.speech_prefix_p1 = self._prefix_data_p1.heavy_swat()
	self.city_swat.speech_prefix_p2 = self._speech_prefix_p2
	self.city_swat.speech_prefix_count = 4
	self.city_swat.access = "swat"
	self.city_swat.no_retreat = nil
	self.city_swat.dodge = presets.dodge.athletic
	self.city_swat.chatter = presets.enemy_chatter.swat
	self.city_swat.melee_weapon = "knife_1"
	self.city_swat.steal_loot = true
	self.city_swat.has_alarm_pager = true
end)

Hooks:PostHook(CharacterTweakData, "_init_sniper", "fraypost_sniper", function(self, presets)
	self.sniper = deep_clone(presets.base)
	self.sniper.tags = { "law", "sniper", "dense", "special" }
	self.sniper.experience = {}
	self.sniper.weapon = presets.weapon.rhythmsniper --this is important, makes them use the mini turret sniper mode.
	self.sniper.detection = presets.detection.sniper
	self.sniper.damage.hurt_severity = presets.hurt_severities.no_hurts --minimize sniper annoyance, just shoot the cunts.
	self.sniper.allowed_stances = {
		cbt = true
	}
	self.sniper.HEALTH_INIT = 1
	self.sniper.headshot_dmg_mul = 2
	self.sniper.move_speed = presets.move_speed.simple_consistency
	self.sniper.shooting_death = false
	self.sniper.no_move_and_shoot = true
	self.sniper.move_and_shoot_cooldown = 1
	self.sniper.suppression = nil --i dont want to put stalwart versions of suppression here due to it hampering the sniper's ability to hold down areas properly.
	self.sniper.ecm_vulnerability = 0
	self.sniper.ecm_hurts = {
		ears = {
			max_duration = 3,
			min_duration = 1
		}
	}
	self.sniper.weapon_voice = "1"
	self.sniper.experience.cable_tie = "tie_swat"
	self.sniper.speech_prefix_p1 = self._prefix_data_p1.cop()
	self.sniper.speech_prefix_p2 = "n"
	self.sniper.speech_prefix_count = 4
	self.sniper.priority_shout = "f34"
	self.sniper.access = "sniper"
	self.sniper.no_retreat = nil
	self.sniper.no_arrest = true
	self.sniper.chatter = presets.enemy_chatter.no_chatter
	self.sniper.steal_loot = nil
	self.sniper.rescue_hostages = false
	self.sniper.die_sound_event = "shd_x02a_any_3p_01"
	self.sniper.spawn_sound_event = "mga_deploy_snipers"

	self.armored_sniper = deep_clone(self.sniper)
	self.armored_sniper.HEALTH_INIT = 6
	self.armored_sniper.headshot_dmg_mul = 6
	self.armored_sniper.dodge = presets.dodge.heavy
	self.armored_sniper.move_speed = presets.move_speed.simple_consistency
	self.armored_sniper.damage.hurt_severity = presets.hurt_severities.no_hurts
	table.insert(self._enemy_list, "armored_sniper")

	self.assault_sniper = deep_clone(self.sniper)
	self.assault_sniper.HEALTH_INIT = 20
	self.assault_sniper.headshot_dmg_mul = 6
	self.assault_sniper.dodge = presets.dodge.athletic
	self.assault_sniper.damage.fire_damage_mul = 24
	table.insert(self._enemy_list, "assault_sniper")

end)

Hooks:PostHook(CharacterTweakData, "_init_gangster", "fraypost_gangster", function(self, presets)
	local job = Global.level_data and Global.level_data.level_id
	self.gangster.HEALTH_INIT = 4
	self.gangster.headshot_dmg_mul = 12
	self.gangster.ecm_vulnerability = 0
	self.gangster.speed_mul = 0.7
	if job == "nightclub" or job == "short2_stage1" or job == "jolly" or job == "spa" then
		self.gangster.speech_prefix_p1 = "rt"
		self.gangster.speech_prefix_p2 = nil
		self.gangster.speech_prefix_count = 2
	elseif job == "alex_2" then
		self.gangster.speech_prefix_p1 = "ict"
		self.gangster.speech_prefix_p2 = nil
		self.gangster.speech_prefix_count = 2
	elseif job == "welcome_to_the_jungle_1" then
		self.gangster.speech_prefix_p1 = "bik"
		self.gangster.speech_prefix_p2 = nil
		self.gangster.speech_prefix_count = 2
	else
		self.gangster.speech_prefix_p1 = "lt"
		self.gangster.speech_prefix_p2 = nil
		self.gangster.speech_prefix_count = 2
	end
	self.gangster.chatter = {
		aggressive = true,
		retreat = true,
		contact = true,
		go_go = true,
		suppress = true,
		enemyidlepanic = true
	}
end)

Hooks:PostHook(CharacterTweakData, "_init_mobster", "fraypost_mobster", function(self, presets)
	local job = Global.level_data and Global.level_data.level_id
	self.mobster.HEALTH_INIT = 4
	self.mobster.headshot_dmg_mul = 12
	self.mobster.ecm_vulnerability = 0
	self.mobster.speed_mul = 0.7
	self.mobster.speech_prefix_p1 = "rt"
	self.mobster.speech_prefix_p2 = nil
	self.mobster.speech_prefix_count = 2
	self.mobster.chatter = {
		aggressive = true,
		retreat = true,
		contact = true,
		go_go = true,
		suppress = true,
		enemyidlepanic = true
	}
end)

Hooks:PostHook(CharacterTweakData, "_init_biker", "fraypost_biker", function(self, presets)
	self.biker.HEALTH_INIT = 4
	self.biker.headshot_dmg_mul = 12
	self.biker.speech_prefix_p1 = "bik"
	self.biker.speech_prefix_p2 = nil
	self.biker.speech_prefix_count = 2
	self.biker.ecm_vulnerability = 0
	self.biker.speed_mul = 0.7
	self.biker.chatter = {
		aggressive = true,
		retreat = true,
		contact = true,
		go_go = true,
		suppress = true,
		enemyidlepanic = true
	}
	local job = Global.level_data and Global.level_data.level_id
	if job == "mex" or job == "mex_cooking" then
		self.biker.access = "security"
	else
		self.biker.access = "gangster"
	end
end)

Hooks:PostHook(CharacterTweakData, "_init_bolivians", "fraypost_bolivians", function(self, presets)
	self.bolivian.HEALTH_INIT = 4
	self.bolivian.headshot_dmg_mul = 12
	self.bolivian.speech_prefix_p1 = "lt"
	self.bolivian.speech_prefix_p2 = nil
	self.bolivian.speech_prefix_count = 2
	self.bolivian.ecm_vulnerability = 0
	self.bolivian.speed_mul = 0.7
	self.bolivian.chatter = {
		aggressive = true,
		retreat = true,
		contact = true,
		go_go = true,
		suppress = true,
		enemyidlepanic = true
	}
	self.bolivian_indoors.HEALTH_INIT = 6
	self.bolivian_indoors.headshot_dmg_mul = 12
	self.bolivian_indoors.speech_prefix_p1 = "lt"
	self.bolivian_indoors.speech_prefix_p2 = nil
	self.bolivian_indoors.speech_prefix_count = 2
	self.bolivian_indoors.ecm_vulnerability = 0
	self.bolivian_indoors.speed_mul = 0.7
	self.bolivian_indoors.chatter = {
		aggressive = true,
		retreat = true,
		contact = true,
		go_go = true,
		suppress = true,
		enemyidlepanic = true
	}
	self.bolivian_indoors_mex = deep_clone(self.bolivian_indoors)
	self.bolivian_indoors_mex.has_alarm_pager = true
	local job = Global.level_data and Global.level_data.level_id
	if job == "mex" or job == "mex_cooking" then
		self.bolivian_indoors_mex.access = "security"
	else
		self.bolivian_indoors_mex.access = "gangster"
	end
end)

Hooks:PostHook(CharacterTweakData, "_init_old_hoxton_mission", "fraypost_hoxton", function(self, presets)
	self.old_hoxton_mission.move_speed = presets.move_speed.teamai
	self.old_hoxton_mission.detection = presets.detection.gang_member
	self.old_hoxton_mission.dodge = nil
	self.old_hoxton_mission.crouch_move = false
	self.old_hoxton_mission.suppression = nil
	self.old_hoxton_mission.buddy = true
	self.old_hoxton_mission.weapon = deep_clone(presets.weapon.fbigod)
end)

function CharacterTweakData:_init_spa_vip(presets)
	self.spa_vip = deep_clone(self.old_hoxton_mission)
	self.spa_vip.dodge = nil
	self.spa_vip.buddy = true
	self.spa_vip.move_speed = presets.move_speed.teamai
	self.spa_vip.crouch_move = false
	self.spa_vip.suppression = nil
	self.spa_vip.weapon = deep_clone(presets.weapon.fbigod)
	self.spa_vip.spotlight_important = 100
	self.spa_vip.is_escort = nil
	self.spa_vip.escort_idle_talk = nil
end

Hooks:PostHook(CharacterTweakData, "_init_cop", "fraypost_cop", function(self, presets)
	self.cop.HEALTH_INIT = 4
	self.cop.headshot_dmg_mul = 4
	if level == "kosugi" or level == "kosugi_hh" then
		self.cop.access = "security"
	else
		self.cop.access = "swat"
	end
	self.cop.ecm_vulnerability = 1
	self.cop.speed_mul = 0.85
	self.cop.ecm_hurts = {
		ears = {
			max_duration = 2,
			min_duration = 2
		}
	}
	self.cop.damage.hurt_severity = presets.hurt_severities.hordemook
	self.cop_moss = deep_clone(self.cop)
	self.cop_moss.tags = { "law", "punk_rage" }

	if level == "kosugi" or level == "kosugi_hh" then
		self.cop_moss.access = "security"
	else
		self.cop_moss.access = "swat"
	end

	if self.tweak_data and self.tweak_data.levels then
		local faction = self.tweak_data.levels:get_ai_group_type()
		if faction == "america" then
			self.cop.melee_weapon = "baton"
			self.cop_moss.melee_weapon = "baton"
		else
			self.cop.melee_weapon = nil
			self.cop_moss.melee_weapon = nil
		end
	end
end)

Hooks:PostHook(CharacterTweakData, "_init_gensec", "fraypost_gensec", function(self, presets)
	self.gensec.HEALTH_INIT = 4
	self.gensec.speed_mul = 0.85
	self.gensec.headshot_dmg_mul = 4
	self.gensec.chatter = presets.enemy_chatter.security
	self.gensec.ecm_hurts = {
		ears = {
			max_duration = 2,
			min_duration = 2
		}
	}
end)

Hooks:PostHook(CharacterTweakData, "_init_security", "fraypost_secsec", function(self, presets)
	self.security.HEALTH_INIT = 4
	self.security.headshot_dmg_mul = 4
	self.security.speed_mul = 0.85
	self.security.chatter = presets.enemy_chatter.security
	self.security.ecm_hurts = {
		ears = {
			max_duration = 2,
			min_duration = 2
		}
	}
	-- if i fucked something i'm going to kill
	self.security_undominatable.HEALTH_INIT = 4
	self.security_undominatable.headshot_dmg_mul = 4
	self.security_undominatable.speed_mul = 0.85
	self.security_undominatable.chatter = presets.enemy_chatter.security
	self.security_undominatable.ecm_hurts = {
		ears = {
			max_duration = 2,
			min_duration = 2
		}
	}
	self.mute_security_undominatable.HEALTH_INIT = 4
	self.mute_security_undominatable.headshot_dmg_mul = 4
	self.mute_security_undominatable.speed_mul = 0.85
	self.mute_security_undominatable.chatter = presets.enemy_chatter.security
	self.mute_security_undominatable.ecm_hurts = {
		ears = {
			max_duration = 2,
			min_duration = 2
		}
	}
	-- why
	self.security_mex.HEALTH_INIT = 4
	self.security_mex.headshot_dmg_mul = 4
	self.security_mex.speed_mul = 0.85
	self.security_mex.chatter = presets.enemy_chatter.security
	self.security_mex.ecm_hurts = {
		ears = {
			max_duration = 2,
			min_duration = 2
		}
	}
end)

Hooks:PostHook(CharacterTweakData, "_init_mobster_boss", "fraypost_mboss", function(self, presets)
	self.mobster_boss.damage.hurt_severity = presets.hurt_severities.no_hurts_no_tase
end)

Hooks:PostHook(CharacterTweakData, "_init_biker_boss", "fraypost_bboss", function(self, presets)
	self.biker_boss.damage.hurt_severity = presets.hurt_severities.no_hurts_no_tase
end)

Hooks:PostHook(CharacterTweakData, "_init_chavez_boss", "fraypost_cboss", function(self, presets)
	self.chavez_boss.damage.hurt_severity = presets.hurt_severities.no_hurts_no_tase
end)

Hooks:PostHook(CharacterTweakData, "_init_drug_lord_boss", "fraypost_dboss", function(self, presets)
	self.drug_lord_boss.damage.hurt_severity = presets.hurt_severities.no_hurts_no_tase
end)

function CharacterTweakData:_init_triad_boss(presets)
	self.triad_boss = deep_clone(presets.base)
	self.triad_boss.tags = { "takedown" }
	self.triad_boss.experience = {}
	self.triad_boss.weapon = deep_clone(presets.weapon.civil)
	self.triad_boss.weapon.is_flamethrower.melee_speed = nil
	self.triad_boss.weapon.is_flamethrower.melee_dmg = nil
	self.triad_boss.weapon.is_flamethrower.melee_retry_delay = nil
	self.triad_boss.detection = presets.detection.normal
	self.triad_boss.extreme_ai_priority = true
	self.triad_boss.true_boss = true
	self.triad_boss.HEALTH_INIT = 270
	self.triad_boss.headshot_dmg_mul = 1
	self.triad_boss.damage.hurt_severity = presets.hurt_severities.no_hurts
	self.triad_boss.damage.explosion_damage_mul = 0.5
	self.triad_boss.can_be_tased = false
	self.triad_boss.suppression = nil
	self.triad_boss.move_speed = presets.move_speed.slow
	self.triad_boss.allowed_stances = {
		cbt = true
	}
	self.triad_boss.allowed_poses = {
		stand = true
	}
	self.triad_boss.crouch_move = false
	self.triad_boss.no_run_start = true
	self.triad_boss.no_run_stop = true
	self.triad_boss.no_retreat = true
	self.triad_boss.no_arrest = true
	self.triad_boss.surrender = nil
	self.triad_boss.ecm_vulnerability = 0
	self.triad_boss.ecm_hurts = {
		ears = {
			max_duration = 0,
			min_duration = 0
		}
	}
	self.triad_boss.weapon_voice = "3"
	self.triad_boss.experience.cable_tie = "tie_swat"
	self.triad_boss.access = "gangster"
	self.triad_boss.speech_prefix_p1 = "bb"
	self.triad_boss.speech_prefix_p2 = "n"
	self.triad_boss.speech_prefix_count = 1
	self.triad_boss.die_sound_event = "Play_yuw_pent_death"
	self.triad_boss.rescue_hostages = false
	self.triad_boss.melee_weapon_dmg_multiplier = 2.5
	self.triad_boss.steal_loot = nil
	self.triad_boss.calls_in = nil
	self.triad_boss.chatter = presets.enemy_chatter.no_chatter
	self.triad_boss.use_radio = nil
	self.triad_boss.use_animation_on_fire_damage = false
	self.triad_boss.flammable = false
	self.triad_boss.immune_to_knock_down = true
	self.triad_boss.immune_to_concussion = true
	self.triad_boss.can_reload_while_moving_tmp = true
	self.triad_boss.no_headshot_add_mul = true
	self.triad_boss.bullet_damage_only_from_front = true
	self.triad_boss.player_health_scaling_mul = 1.5
	self.triad_boss.throwable = "molotov"
	self.triad_boss.aoe_damage_data = {
		verification_delay = 0.3,
		activation_range = 300,
		activation_delay = 1,
		env_tweak_name = "triad_boss_aoe_fire",
		play_voiceline = true,
		check_player = true,
		check_npc_slotmask = {
			"criminals",
			-2,
			-3
		}
	}
	self.triad_boss.invulnerable_to_slotmask = { "enemies", 17 }

	table.insert(self._enemy_list, "triad_boss")

	self.triad_boss_no_armor = deep_clone(self.gangster)
	self.triad_boss_no_armor.suspicious = nil
	self.triad_boss_no_armor.detection = presets.detection.normal
	self.triad_boss_no_armor.damage.hurt_severity = presets.hurt_severities.no_hurts
	self.triad_boss_no_armor.move_speed = presets.move_speed.very_fast
	self.triad_boss_no_armor.dodge = presets.dodge.athletic
	self.triad_boss_no_armor.crouch_move = nil
	self.triad_boss_no_armor.suppression = nil
	self.triad_boss_no_armor.can_be_tased = false
	self.triad_boss_no_armor.no_retreat = true
	self.triad_boss_no_armor.no_arrest = true
	self.triad_boss_no_armor.surrender = nil
	self.triad_boss_no_armor.ecm_vulnerability = 0
	self.triad_boss_no_armor.ecm_hurts = {
		ears = {
			max_duration = 0,
			min_duration = 0
		}
	}
	self.triad_boss_no_armor.rescue_hostages = false
	self.triad_boss_no_armor.steal_loot = nil
	self.triad_boss_no_armor.calls_in = nil
	self.triad_boss_no_armor.chatter = presets.enemy_chatter.no_chatter
	self.triad_boss_no_armor.use_radio = nil
	self.triad_boss_no_armor.radio_prefix = "fri_"
	self.triad_boss_no_armor.use_animation_on_fire_damage = false
	self.triad_boss_no_armor.immune_to_knock_down = true
	self.triad_boss_no_armor.immune_to_concussion = true

	table.insert(self._enemy_list, "triad_boss_no_armor")
end

--LANDMARK: WITCH

--difficulty tweaks begin here.

function CharacterTweakData:_set_normal()
	self:_multiply_all_hp(2, 1)
	self:_multiply_all_speeds(1, 1)
	self:_set_characters_crumble_chance(0.5, 0.3, 0.9)

	FRAYSetHectorBossShotgunFalloff(self)
	FRAYSetBossHealth(self, 600)
	FRAYSetGangMemberDamage(self)

	self:_set_characters_weapon_preset("civil")

	self.flashbang_multiplier = 1
	self.concussion_multiplier = 1

	--FBI tweak
	self.fbi.move_speed = self.presets.move_speed.simple_consistency
	self.fbi.speed_mul = 1.1
	self.fbi_girl.move_speed = self.presets.move_speed.simple_consistency
	self.fbi_girl.speed_mul = 1.1
	self.gangster_ninja.move_speed = self.presets.move_speed.simple_consistency
	self.gangster_ninja.speed_mul = 1.1
	self.fbi_pager.move_speed = self.presets.move_speed.simple_consistency
	self.fbi_pager.speed_mul = 1.1
	FRAYSetSpoocAttackTimeout(self)
	FRAYSetMinObjInterruptDistances(self)
end

--HARD setup begins here, landmark (POW)

function CharacterTweakData:_set_hard()
	self:_multiply_all_hp(2, 1)
	self:_multiply_all_speeds(1, 1)
	self:_set_characters_crumble_chance(0.5, 0.3, 0.9)

	FRAYSetHectorBossShotgunFalloff(self)
	FRAYSetBossHealth(self, 600)
	FRAYSetGangMemberDamage(self)

	self:_set_characters_weapon_preset("civil")


	self.flashbang_multiplier = 1
	self.concussion_multiplier = 1

	--FBI tweak
	self.fbi.move_speed = self.presets.move_speed.simple_consistency
	self.fbi.speed_mul = 1.1
	self.fbi_girl.move_speed = self.presets.move_speed.simple_consistency
	self.fbi_girl.speed_mul = 1.1
	self.gangster_ninja.move_speed = self.presets.move_speed.simple_consistency
	self.gangster_ninja.speed_mul = 1.1
	self.fbi_pager.move_speed = self.presets.move_speed.simple_consistency
	self.fbi_pager.speed_mul = 1.1
	FRAYSetSpoocAttackTimeout(self)
	FRAYSetMinObjInterruptDistances(self)
end

--VH setup, landmark (DOG)
function CharacterTweakData:_set_overkill()
	self:_multiply_all_hp(4, 1)
	self:_multiply_all_speeds(1, 1)
	self:_set_characters_crumble_chance(0.4, 0.2, 0.9)

	self.tank_mini.HEALTH_INIT = 4000
	FRAYSetHectorBossShotgunFalloff(self)
	FRAYSetBossHealth(self, 600)
	FRAYSetPhalanx(self, 100, 400, 600, 800)

	FRAYSetGangMemberDamage(self)

	self:_set_characters_weapon_preset("civil")

	FRAYSetSpoocAttackTimeout(self)

	--fbi setup.
	self.fbi.move_speed = self.presets.move_speed.simple_consistency
	self.fbi.speed_mul = 1.1
	self.fbi_xc45.move_speed = self.presets.move_speed.simple_consistency
	self.fbi_xc45.speed_mul = 1.1
	self.fbi_girl.move_speed = self.presets.move_speed.simple_consistency
	self.fbi_girl.speed_mul = 1.1
	self.gangster_ninja.move_speed = self.presets.move_speed.simple_consistency
	self.gangster_ninja.speed_mul = 1.1
	self.fbi_pager.move_speed = self.presets.move_speed.simple_consistency
	self.fbi_pager.speed_mul = 1.1
	--Shield speed setup
	self.shield.move_speed = self.presets.move_speed.simple_consistency
	--Movespeed setups.
	self.swat.move_speed = self.presets.move_speed.simple_consistency
	self.city_swat.move_speed = self.presets.move_speed.simple_consistency
	self.fbi_swat.move_speed = self.presets.move_speed.simple_consistency
	self.heavy_swat.move_speed = self.presets.move_speed.simple_consistency
	self.fbi_heavy_swat.move_speed = self.presets.move_speed.simple_consistency
	--special movespeed
	self.taser.move_speed = self.presets.move_speed.simple_consistency
	self.medic.move_speed = self.presets.move_speed.simple_consistency

	self.flashbang_multiplier = 1
	self.concussion_multiplier = 1
	FRAYSetMinObjInterruptDistances(self)
end

--OVK setup, landmark (QBY)

function CharacterTweakData:_set_overkill_145()
	self:_multiply_all_hp(4, 1)
	self:_set_characters_crumble_chance(0.4, 0.2, 0.9)

	self.tank_mini.HEALTH_INIT = 4000
	FRAYSetHectorBossShotgunFalloff(self)
	FRAYSetBossHealth(self, 600)
	FRAYSetPhalanx(self, 100, 400, 600, 800)

	self:_multiply_all_speeds(1, 1)

	FRAYSetGangMemberDamage(self)

	self:_set_characters_weapon_preset("civil")

	FRAYSetSpoocAttackTimeout(self)

	if managers.modifiers and managers.modifiers:check_boolean("TotalAnarchy") then
		--fbi setup
		self.fbi.dodge = self.presets.dodge.ninja_complex
		self.fbi.move_speed = self.presets.move_speed.anarchy_consistency
		self.fbi_girl.dodge = self.presets.dodge.ninja_complex
		self.fbi_girl.move_speed = self.presets.move_speed.anarchy_consistency
		self.gangster_ninja.dodge = self.presets.dodge.ninja_complex
		self.gangster_ninja.move_speed = self.presets.move_speed.anarchy_consistency
		self.fbi_pager.dodge = self.presets.dodge.ninja_complex
		self.fbi_pager.move_speed = self.presets.move_speed.anarchy_consistency
		self.fbi_xc45.weapon = self.presets.weapon.fbigod
		self.fbi_xc45.move_speed = self.presets.move_speed.anarchy_consistency

		--movespeed setup
		self.sniper.move_speed = self.presets.move_speed.lightning_constant

		--dodge setup.
		self.swat.dodge = self.presets.dodge.athletic_complex
		self.fbi_swat.dodge = self.presets.dodge.athletic_complex
		self.city_swat.dodge = self.presets.dodge.athletic_complex
		self.heavy_swat.dodge = self.presets.dodge.heavy_complex
		self.fbi_heavy_swat.dodge = self.presets.dodge.heavy_complex
		self.spooc.dodge = self.presets.dodge.ninja_complex
		self.flashbang_multiplier = 1.5
		self.concussion_multiplier = 1
	else
		--fbi setup.
		self.fbi.move_speed = self.presets.move_speed.simple_consistency
		self.fbi.speed_mul = 1.1
		self.fbi_xc45.move_speed = self.presets.move_speed.simple_consistency
		self.fbi_xc45.speed_mul = 1.1
		self.fbi_girl.move_speed = self.presets.move_speed.simple_consistency
		self.fbi_girl.speed_mul = 1.1
		self.gangster_ninja.move_speed = self.presets.move_speed.simple_consistency
		self.gangster_ninja.speed_mul = 1.1
		self.fbi_pager.move_speed = self.presets.move_speed.simple_consistency
		self.fbi_pager.speed_mul = 1.1
		--Shield speed setup
		self.shield.move_speed = self.presets.move_speed.simple_consistency
		--Movespeed setups.
		self.swat.move_speed = self.presets.move_speed.simple_consistency
		self.city_swat.move_speed = self.presets.move_speed.simple_consistency
		self.fbi_swat.move_speed = self.presets.move_speed.simple_consistency
		self.heavy_swat.move_speed = self.presets.move_speed.simple_consistency
		self.fbi_heavy_swat.move_speed = self.presets.move_speed.simple_consistency
		self.armored_sniper.move_speed = self.presets.move_speed.simple_consistency
		--special movespeed
		self.taser.move_speed = self.presets.move_speed.simple_consistency
		self.medic.move_speed = self.presets.move_speed.simple_consistency
		self.flashbang_multiplier = 1.25
		self.concussion_multiplier = 1
	end

	if managers.modifiers and managers.modifiers:check_boolean("telespooc") then
		self.spooc.move_speed = self.presets.move_speed.speedofsoundsonic
	end
	FRAYSetMinObjInterruptDistances(self)
end

--MH setup, landmark (1ST ATT)

function CharacterTweakData:_set_easy_wish()
	self:_multiply_all_hp(4, 1)
	self:_set_characters_crumble_chance(0.3, 0.15, 0.75)

	self.tank_mini.HEALTH_INIT = 4000
	FRAYSetBossHealth(self, 900)

	self:_multiply_all_speeds(1, 1)

	FRAYSetGangMemberDamage(self)

	self:_set_characters_weapon_preset("complex")

	FRAYSetSpoocAttackTimeout(self)
	--fbi setup
	self.fbi.dodge = self.presets.dodge.athletic_complex
	self.fbi.move_speed = self.presets.move_speed.complex_consistency
	self.fbi_girl.dodge = self.presets.dodge.athletic_complex
	self.fbi_girl.move_speed = self.presets.move_speed.complex_consistency
	self.gangster_ninja.dodge = self.presets.dodge.athletic_complex
	self.gangster_ninja.move_speed = self.presets.move_speed.complex_consistency
	self.fbi_pager.dodge = self.presets.dodge.athletic_complex
	self.fbi_pager.move_speed = self.presets.move_speed.complex_consistency
	self.fbi_xc45.dodge = self.presets.dodge.athletic_complex
	self.fbi_xc45.move_speed = self.presets.move_speed.complex_consistency

	--Movespeed setups.
	self.swat.move_speed = self.presets.move_speed.civil_consistency
	self.city_swat.move_speed = self.presets.move_speed.civil_consistency
	self.fbi_swat.move_speed = self.presets.move_speed.civil_consistency
	self.heavy_swat.move_speed = self.presets.move_speed.civil_consistency
	self.fbi_heavy_swat.move_speed = self.presets.move_speed.civil_consistency
	--special movespeed
	self.taser.move_speed = self.presets.move_speed.civil_consistency
	self.medic.move_speed = self.presets.move_speed.civil_consistency
	self.shield.move_speed = self.presets.move_speed.civil_consistency
	--dodge setups.
	self.swat.dodge = self.presets.dodge.heavy_complex
	self.fbi_swat.dodge = self.presets.dodge.heavy_complex
	self.city_swat.dodge = self.presets.dodge.heavy_complex
	--Shield explosive resist
	self.shield.damage.explosion_damage_mul = 0.5
	FRAYSetPhalanx(self, 200, 400, 800, 800)
	self.flashbang_multiplier = 1.25
	self.concussion_multiplier = 1
	FRAYSetMinObjInterruptDistances(self)
end

--DW setup, landmark (2ND IMP)

function CharacterTweakData:_set_overkill_290()
	self:_multiply_all_hp(4, 1)
	self:_set_characters_crumble_chance(0.3, 0.15, 0.75)

	self.tank_mini.HEALTH_INIT = 4000
	FRAYSetHectorBossShotgunFalloff(self, true)
	FRAYSetBossHealth(self, 900)

	self:_multiply_all_speeds(1, 1)

	FRAYSetGangMemberDamage(self)

	self:_set_characters_weapon_preset("complex")

	FRAYSetSpoocAttackTimeout(self)

	--fbi setup
	self.fbi.dodge = self.presets.dodge.ninja_complex
	self.fbi.move_speed = self.presets.move_speed.anarchy_consistency
	self.fbi_girl.dodge = self.presets.dodge.ninja_complex
	self.fbi_girl.move_speed = self.presets.move_speed.anarchy_consistency
	self.gangster_ninja.dodge = self.presets.dodge.ninja_complex
	self.gangster_ninja.move_speed = self.presets.move_speed.anarchy_consistency
	self.fbi_pager.dodge = self.presets.dodge.ninja_complex
	self.fbi_pager.move_speed = self.presets.move_speed.anarchy_consistency
	self.fbi_xc45.dodge = self.presets.dodge.ninja_complex
	self.fbi_xc45.move_speed = self.presets.move_speed.anarchy_consistency
	--Movespeed setups.
	self.swat.move_speed = self.presets.move_speed.anarchy_consistency
	self.city_swat.move_speed = self.presets.move_speed.anarchy_consistency
	self.fbi_swat.move_speed = self.presets.move_speed.anarchy_consistency
	self.heavy_swat.move_speed = self.presets.move_speed.anarchy_consistency
	self.fbi_heavy_swat.move_speed = self.presets.move_speed.anarchy_consistency
	--special movespeed
	self.taser.move_speed = self.presets.move_speed.anarchy_consistency
	self.medic.move_speed = self.presets.move_speed.anarchy_consistency
	self.shield.move_speed = self.presets.move_speed.anarchy_consistency
	--dodge setups.
	self.swat.dodge = self.presets.dodge.athletic_complex
	self.fbi_swat.dodge = self.presets.dodge.athletic_complex
	self.city_swat.dodge = self.presets.dodge.athletic_complex
	self.heavy_swat.dodge = self.presets.dodge.heavy_complex
	self.fbi_heavy_swat.dodge = self.presets.dodge.heavy_complex
	self.spooc.dodge = self.presets.dodge.ninja_complex
	--Shield explosive resist
	self.shield.damage.explosion_damage_mul = 0.5
	FRAYSetPhalanx(self, 200, 400, 800, 800)
	self.flashbang_multiplier = 1.25
	self.concussion_multiplier = 1
	FRAYSetMinObjInterruptDistances(self)
end

--DS setup, the 3rd Strike is what counts. (3RD STR)

function CharacterTweakData:_set_sm_wish()
	self:_multiply_all_hp(4, 1)
	self:_set_characters_crumble_chance(0.25, 0.15, 0.6)

	self.tank.HEALTH_INIT = 2000
	self.tank_mini.HEALTH_INIT = 4000
	self.tank_medic.HEALTH_INIT = 2000
	FRAYSetHectorBossShotgunFalloff(self, true)
	FRAYSetBossHealth(self, 900)

	self:_multiply_all_speeds(1, 1)

	FRAYSetGangMemberDamage(self)

	self:_set_characters_weapon_preset("anarchy")

	FRAYSetSpoocAttackTimeout(self)

	--fbi setup
	self.fbi.dodge = self.presets.dodge.ninja_complex
	self.fbi.move_speed = self.presets.move_speed.anarchy_consistency
	self.fbi_girl.dodge = self.presets.dodge.ninja_complex
	self.fbi_girl.move_speed = self.presets.move_speed.anarchy_consistency
	self.gangster_ninja.dodge = self.presets.dodge.ninja_complex
	self.gangster_ninja.move_speed = self.presets.move_speed.anarchy_consistency
	self.fbi_pager.dodge = self.presets.dodge.ninja_complex
	self.fbi_pager.move_speed = self.presets.move_speed.anarchy_consistency
	self.fbi_xc45.weapon = self.presets.weapon.fbigod
	self.fbi_xc45.move_speed = self.presets.move_speed.anarchy_consistency

	--Anti-Fire DOT setup
	self.taser.DAMAGE_CLAMP_FIREDOT = 5 --Tasers and Shields need significant resistance to fire.
	self.tank.DAMAGE_CLAMP_FIREDOT = 10
	self.shield.DAMAGE_CLAMP_FIREDOT = 5
	--This is weird, but makes snipers technically be active sooner, which is good.
	self.sniper.move_speed = self.presets.move_speed.lightning_constant
	self.shield.spawn_sound_event = "hos_shield_identification" --Come with me if you want to live.
	--Movespeed setups.
	self.swat.move_speed = self.presets.move_speed.anarchy_consistency
	self.city_swat.move_speed = self.presets.move_speed.anarchy_consistency
	self.fbi_swat.move_speed = self.presets.move_speed.anarchy_consistency
	self.heavy_swat.move_speed = self.presets.move_speed.anarchy_consistency
	self.fbi_heavy_swat.move_speed = self.presets.move_speed.anarchy_consistency
	--special movespeed
	self.taser.move_speed = self.presets.move_speed.anarchy_consistency
	self.medic.move_speed = self.presets.move_speed.anarchy_consistency
	self.shield.move_speed = self.presets.move_speed.anarchy_consistency
	--dodge setup.
	self.swat.dodge = self.presets.dodge.athletic_complex
	self.fbi_swat.dodge = self.presets.dodge.athletic_complex
	self.city_swat.dodge = self.presets.dodge.athletic_complex
	self.heavy_swat.dodge = self.presets.dodge.heavy_complex
	self.fbi_heavy_swat.dodge = self.presets.dodge.heavy_complex
	self.spooc.dodge = self.presets.dodge.ninja_complex
	--Explosive resist for certain enemies.
	self.shield.damage.explosion_damage_mul = 0.25
	self.tank.damage.explosion_damage_mul = 0.7
	self.tank_medic.damage.explosion_damage_mul = 0.7
	self.tank_mini.damage.explosion_damage_mul = 0.7

	FRAYSetPhalanx(self, 300, 40, 80, 80)
	self.flashbang_multiplier = 1.5
	self.concussion_multiplier = 1
	FRAYSetMinObjInterruptDistances(self)
end

--Bot weapons, here we go
local FRAYBotWeaponHooks = {
	{ "_init_russian", "fraypost_russian", { { "russian", "wpn_fps_ass_amcar_npc" } } },
	{ "_init_german", "fraypost_german", { { "german", "wpn_fps_shot_r870_npc" } } },
	{ "_init_spanish", "fraypost_spanish", { { "spanish", "wpn_fps_lmg_m249_npc" } } },
	{ "_init_american", "fraypost_american", { { "american", "wpn_fps_ass_ak5_npc" } } },
	{ "_init_jowi", "fraypost_jowi", { { "jowi", "wpn_fps_snp_tti_npc" } } },
	{ "_init_old_hoxton", "fraypost_hoxton", { { "old_hoxton", "wpn_fps_ass_m14_npc" } } },
	{ "_init_clover", "fraypost_clover", { { "female_1", "wpn_fps_ass_l85a2_npc" } } },
	{ "_init_dragan", "fraypost_dragan", { { "dragan", "wpn_fps_ass_vhs_npc" } } },
	{ "_init_jacket", "fraypost_jacket", { { "jacket", "wpn_fps_smg_cobray_npc" } } },
	{ "_init_bonnie", "fraypost_bonnie", { { "bonnie", "wpn_fps_shot_b682_npc" } } },
	{ "_init_sokol", "fraypost_sokol", { { "sokol", "wpn_fps_ass_asval_npc" } } },
	{ "_init_dragon", "fraypost_dragon", { { "dragon", "wpn_fps_smg_baka_npc" } } },
	{ "_init_bodhi", "fraypost_bodhi", { { "bodhi", "wpn_fps_snp_model70_npc" } } },
	{ "_init_jimmy", "fraypost_jimmy", { { "jimmy", "wpn_fps_smg_sr2_npc" } } },
	{ "_init_sydney", "fraypost_sydney", { { "sydney", "wpn_fps_ass_tecci_npc" } } },
	{ "_init_wild", "fraypost_wild", { { "wild", "wpn_fps_sho_boot_npc" } } },
	{ "_init_chico", "fraypost_chico", { { "chico", "wpn_fps_ass_contraband_npc" } } },
	{ "_init_max", "fraypost_max", { { "max", "wpn_fps_ass_akm_gold_npc" } } },
	{ "_init_joy", "fraypost_joy", { { "joy", "wpn_fps_smg_shepheard_npc" } } },
	{ "_init_myh", "fraypost_myh", { { "myh", "wpn_fps_ass_ching_npc" } } },
	{ "_init_ecp", "fraypost_ecps", { { "ecp_female", "wpn_fps_ass_famas_npc" }, { "ecp_male", "wpn_fps_ass_scar_npc" } } }
}

for _, hook_data in ipairs(FRAYBotWeaponHooks) do
	local init_func = hook_data[1]
	local hook_id = hook_data[2]
	local loadout = hook_data[3]

	Hooks:PostHook(CharacterTweakData, init_func, hook_id, function(self, presets)
		for _, data in ipairs(loadout) do
			local character = self[data[1]]
			character.weapon.weapons_of_choice.primary = data[2]
			character.move_speed = presets.move_speed.teamai
		end
	end)
end

--End Perferred Bot Weapons

function CharacterTweakData:_create_table_structure()
	origin_create_table_structure(self)

	local existing = {}

	for _, weapon_id in ipairs(self.weap_ids or {}) do
		existing[weapon_id] = true
	end

	local function add_weapon(weapon_id, unit_name)
		if existing[weapon_id] then
			return
		end

		table.insert(self.weap_ids, weapon_id)
		table.insert(self.weap_unit_names, Idstring(unit_name))
		existing[weapon_id] = true
	end

	local weapon_additions = {
		{ "m4_cooler", "units/pd2_dlc_gitgud/weapons/wpn_npc_m4_(cooler)/wpn_npc_m4_(cooler)" },
		{ "s553_zeal", "units/pd2_dlc_gitgud/weapons/wpn_npc_s553/wpn_npc_s553" },
		{ "lazer", "units/pd2_dlc_gitgud/weapons/wpn_npc_lazer/wpn_npc_lazer" },
		{ "tazerlazer", "units/pd2_mod_zmansion/weapons/wpn_npc_tazerlazer/wpn_npc_tazerlazer" },
		{ "blazter", "units/pd2_dlc_gitgud/weapons/wpn_npc_blazter/wpn_npc_blazter" },
		{ "bayou_spas", "units/payday2/weapons/wpn_npc_bayou/wpn_npc_bayou" },
		{ "quagmire", "units/pd2_mod_psc/weapons/wpn_npc_quagmire/wpn_npc_quagmire" },
		{ "galil", "units/payday2/weapons/wpn_npc_galil/wpn_npc_galil" },
		{ "silserbu", "units/pd2_dlc_drm/weapons/wpn_npc_silserbu/wpn_npc_silserbu" },
		{ "xkill", "units/payday2/weapons/wpn_npc_xkill/wpn_npc_xkill" },
		{ "x_xkill", "units/payday2/weapons/wpn_npc_xkill/wpn_npc_x_xkill" },
		{ "streak", "units/pd2_dlc_mad/weapons/wpn_npc_pl14/wpn_npc_pl14" },
		{ "x_streak", "units/pd2_dlc_mad/weapons/wpn_npc_pl14/wpn_npc_x_pl14" },
		{ "kmtac", "units/pd2_dlc_gitgud/weapons/wpn_npc_kmtac/wpn_npc_kmtac" },
		{ "x_kmtac", "units/pd2_dlc_gitgud/weapons/wpn_npc_kmtac/wpn_npc_x_kmtac" },
		{ "trolliam_sidearm", "units/pd2_mod_epictroll/weapons/trolliamsidearm/trolliamsidearm" },
		{ "degle", "units/payday2/weapons/wpn_npc_degle/wpn_npc_degle" },
		{ "m60", "units/pd2_mod_psc/weapons/wpn_npc_m60/wpn_npc_m60" },
		{ "m37", "units/pd2_dlc_drm/weapons/wpn_npc_m37/wpn_npc_m37" },
		{ "chernobog", "units/pd2_mod_psc/weapons/wpn_npc_chernobog/wpn_npc_chernobog" }
	}

	for _, data in ipairs(weapon_additions) do
		add_weapon(data[1], data[2])
	end
end

function CharacterTweakData:character_map()
	local char_map = origin_charmap(self)

	local function ensure_group(group_id, path)
		char_map[group_id] = char_map[group_id] or {
			path = path,
			list = {}
		}
		char_map[group_id].path = char_map[group_id].path or path
		char_map[group_id].list = char_map[group_id].list or {}

		return char_map[group_id]
	end

	local function add_character(group_id, path, unit_name)
		local group = ensure_group(group_id, path)

		for _, existing_unit in ipairs(group.list) do
			if existing_unit == unit_name then
				return
			end
		end

		table.insert(group.list, unit_name)
	end

	local function add_characters(group_id, path, unit_names)
		for _, unit_name in ipairs(unit_names) do
			add_character(group_id, path, unit_name)
		end
	end

	local character_additions = {
		{ "ghosts", "units/pd2_mod_zmansion/characters/", { "ene_true_zeal_cloaker", "ene_true_zeal_rifle", "ene_true_zeal_shotgun", "ene_true_zeal_taser" } },
		{ "additions", "units/payday2/characters/", { "ene_fbi_swat_3", "ene_swat_3", "ene_gangster_ninja_m4", "ene_medic_m4_hh" } },
		{ "bexhh", "units/pd2_dlc_bex/characters/", { "ene_swat_policia_federale_r870_hh", "ene_swat_policia_federale_mp5", "ene_medic_federale_rifle_hh", "ene_medic_federale_r870_hh", "ene_swat_heavy_policia_federale_fbi_r870_hh", "ene_heavy_swat_shield_federale_ds", "ene_bex_ninja_c45", "ene_policia_punk_bronco", "ene_policia_03", "ene_tazer_1" } },
		{ "beatpricks", "units/pd2_mod_beatpricks/characters/", { "ene_cop_3", "ene_cop_2", "ene_cop_1", "ene_cop_4" } },
		{ "drm", "units/pd2_dlc_drm/characters/", { "ene_bulldozer_medic", "ene_bulldozer_minigun", "ene_bulldozer_minigun_classic", "ene_zeal_swat_heavy_sniper", "ene_zeal_armored_light", "ene_murky_heavy_ump", "ene_fbi_heavy_ump", "ene_bulldozer_sniper", "ene_sniper_heavy", "ene_spook_heavy", "ene_taser_heavy", "ene_shield_heavy", "ene_medic_heavy_m4", "ene_medic_heavy_r870", "ene_city_swat_saiga", "ene_medic_carkdown", "ene_ovk_mangler" } },
		{ "gitgud", "units/pd2_dlc_gitgud/characters/", { "ene_zeal_bulldozer", "ene_zeal_bulldozer_2", "ene_zeal_bulldozer_3", "ene_zeal_cloaker", "ene_zeal_swat", "ene_zeal_city_1", "ene_zeal_city_2", "ene_zeal_city_3", "ene_zeal_medic", "ene_zeal_medic_r870", "ene_zeal_swat_heavy", "ene_zeal_swat_heavy_r870", "ene_zeal_swat_shield", "ene_zeal_swat_shield_hh", "ene_zeal_tazer", "ene_zeal_punk_mp5", "ene_zeal_punk_moss", "ene_zeal_punk_bronco", "ene_zeal_fbigod_m4", "ene_zeal_fbigod_c45", "ene_zeal_sniper" } },
		{ "psc", "units/pd2_mod_psc/characters/", { "ene_murky_light_rifle", "ene_murky_heavy_scar", "ene_murky_NH_rifle", "ene_murky_NH_r870", "ene_murky_light_r870", "ene_murky_heavy_r870", "ene_murky_light_ump", "ene_murky_fbigod_m4", "ene_murky_fbigod_c45", "ene_murky_fbigod_c45_DS", "ene_murky_shield", "ene_murky_shield_ld", "ene_murky_DS_shield", "ene_murky_punk_c45", "ene_murky_punk_bronco", "ene_murky_punk_mp5", "ene_murky_punk_moss", "ene_murky_cloaker", "ene_murkywater_medic", "ene_murkywater_medic_r870", "ene_murkywater_tazer", "ene_murkywater_cloaker", "ene_murkywater_bulldozer_1", "ene_murkywater_bulldozer_2", "ene_murkywater_bulldozer_3", "ene_murkywater_bulldozer_4", "ene_murkywater_bulldozer_medic", "ene_murkywater_shield", "ene_murkywater_sniper", "ene_murkywater_heavy", "ene_murkywater_heavy_shotgun", "ene_murkywater_heavy_g36", "ene_murkywater_light_city", "ene_murkywater_light_city_r870", "ene_murkywater_light_fbi_r870", "ene_murkywater_light_fbi", "ene_murkywater_light", "ene_murkywater_light_r870" } },
		{ "ftsu", "units/pd2_mod_ftsu/characters/", { "ene_gensec_fbigod_c45", "ene_gensec_fbigod_m4", "ene_gensec_fbiguard_sg", "ene_gensec_sniper", "ene_gensec_punk_mp5", "ene_gensec_punk_moss", "ene_gensec_punk_bronco" } },
		{ "epictroll", "units/pd2_mod_epictroll/characters/", { "ene_trolliam_calhoun" } },
		{ "hvh", "units/pd2_dlc_hvh/characters/", { "ene_cop_hvh_1", "ene_cop_hvh_2", "ene_cop_hvh_3", "ene_cop_hvh_4", "ene_cop_hvh_moss", "ene_swat_hvh_1", "ene_swat_hvh_2", "ene_swat_hvh_3", "ene_fbi_hvh_1", "ene_fbi_hvh_2", "ene_fbi_hvh_3", "ene_fbigod_hvh_m4", "ene_fbigod_hvh_c45", "ene_spook_hvh_1", "ene_swat_heavy_hvh_1", "ene_swat_heavy_hvh_r870", "ene_tazer_hvh_1", "ene_shield_hvh_1", "ene_shield_hvh_2", "ene_medic_hvh_r870", "ene_medic_hvh_m4", "ene_bulldozer_hvh_1", "ene_bulldozer_hvh_2", "ene_bulldozer_hvh_3", "ene_fbi_swat_hvh_1", "ene_fbi_swat_hvh_2", "ene_fbi_swat_hvh_3", "ene_fbi_heavy_hvh_1", "ene_fbi_heavy_hvh_r870", "ene_sniper_hvh_2", "ene_fbi_swat_shield_ds" } },
		{ "mad", "units/pd2_dlc_mad/characters/", { "civ_male_scientist_01", "civ_male_scientist_02", "ene_akan_fbi_heavy_g36", "ene_akan_fbi_heavy_g36_hh", "ene_akan_fbi_heavy_r870_hh", "ene_akan_fbi_shield_sr2_smg", "ene_akan_fbi_spooc_asval_smg", "ene_akan_fbi_swat_ak47_ass", "ene_akan_fbi_swat_dw_ak47_ass", "ene_akan_fbi_swat_dw_r870", "ene_akan_fbi_swat_r870", "ene_akan_fbi_tank_r870", "ene_akan_fbi_tank_rpk_lmg", "ene_akan_fbi_tank_saiga", "ene_akan_cs_cop_ak47_ass", "ene_akan_cs_cop_akmsu_smg", "ene_akan_cs_cop_asval_smg", "ene_akan_cs_cop_r870", "ene_akan_cs_heavy_ak47_ass", "ene_akan_cs_shield_c45", "ene_akan_cs_swat_ak47_ass", "ene_akan_cs_swat_r870", "ene_akan_cs_swat_sniper_svd_snp", "ene_akan_cs_tazer_ak47_ass", "ene_akan_medic_ak47_ass", "ene_akan_medic_ak47_ass_hh", "ene_akan_medic_r870", "ene_akan_hyper_fbi_akmsu_smg", "ene_akan_hyper_swat_akmsu_smg", "ene_akan_hyper_fbininja_ak47_ass", "ene_akan_hyper_fbininja_c45", "ene_akan_hyper_fbininja_c45_DS", "ene_akan_hyper_DS_shield", "ene_akan_dozer_medic", "ene_akan_dozer_mini" } }
	}

	for _, data in ipairs(character_additions) do
		add_characters(data[1], data[2], data[3])
	end

	return char_map
end

function CharacterTweakData:_multiply_all_hp(hp_mul, hs_mul)
	local function multiply_health(name)
		local char = self[name]

		if char then
			char.HEALTH_INIT = char.HEALTH_INIT * hp_mul
		end
	end

	local function copy_health(source, names)
		local source_char = self[source]

		if not source_char then
			return
		end

		for _, name in ipairs(names) do
			if self[name] then
				self[name].HEALTH_INIT = source_char.HEALTH_INIT
			end
		end
	end

	local function multiply_headshot(name)
		local char = self[name]

		if char and char.headshot_dmg_mul then
			char.headshot_dmg_mul = char.headshot_dmg_mul * hs_mul
		end
	end

	local function copy_headshot(source, names)
		local source_char = self[source]

		if not source_char then
			return
		end

		for _, name in ipairs(names) do
			if self[name] then
				self[name].headshot_dmg_mul = source_char.headshot_dmg_mul
			end
		end
	end

	multiply_health("security")
	copy_health("security", {
		"security_no_pager",
		"security_undominatable",
		"mute_security_undominatable",
		"security_mex",
		"security_mex_no_pager",
		"gensec",
		"gangster",
		"mobster",
		"biker",
		"triad",
		"bolivian",
		"bolivian_indoors",
		"bolivian_indoors_mex",
		"cop",
		"cop_moss",
		"cop_scared"
	})

	multiply_health("fbi")
	copy_health("fbi", { "cop_female", "fbi_girl", "gangster_ninja", "fbi_pager", "fbi_xc45" })

	multiply_health("swat")
	copy_health("swat", { "fbi_swat", "city_swat" })

	multiply_health("heavy_swat")
	copy_health("heavy_swat", { "fbi_heavy_swat" })

	for _, name in ipairs({
		"tank",
		"tank_hw",
		"tank_mini",
		"tank_ftsu",
		"trolliam_epicson",
		"tank_medic",
		"spooc",
		"spooc_heavy",
		"shield",
		"phalanx_minion",
		"phalanx_vip",
		"taser",
		"biker_escape",
		"medic",
		"drug_lord_boss",
		"drug_lord_boss_stealth",
		"triad_boss",
		"triad_boss_no_armor",
		"sniper",
		"armored_sniper",
		"shadow_spooc",
		"shadow_taser",
		"shadow_swat"
	}) do
		multiply_health(name)
	end

	multiply_headshot("security")
	copy_headshot("security", {
		"security_no_pager",
		"security_undominatable",
		"mute_security_undominatable",
		"security_mex",
		"security_mex_no_pager",
		"gensec",
		"gangster",
		"mobster",
		"biker",
		"triad",
		"bolivian",
		"bolivian_indoors",
		"bolivian_indoors_mex",
		"cop",
		"cop_moss",
		"cop_scared"
	})

	multiply_headshot("fbi")
	copy_headshot("fbi", { "cop_female", "fbi_girl", "gangster_ninja", "fbi_pager", "fbi_xc45" })

	multiply_headshot("swat")
	copy_headshot("swat", { "fbi_swat", "city_swat" })

	multiply_headshot("heavy_swat")
	multiply_headshot("fbi_heavy_swat")

	for _, name in ipairs({
		"tank",
		"tank_hw",
		"tank_medic",
		"tank_mini",
		"tank_ftsu",
		"trolliam_epicson",
		"spooc",
		"spooc_heavy",
		"shield",
		"phalanx_minion",
		"phalanx_vip",
		"taser",
		"medic",
		"biker_escape",
		"drug_lord_boss",
		"triad_boss_no_armor",
		"sniper",
		"armored_sniper",
		"shadow_spooc",
		"shadow_swat",
		"shadow_taser"
	}) do
		multiply_headshot(name)
	end
end
