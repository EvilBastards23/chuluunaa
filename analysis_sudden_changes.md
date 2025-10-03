# 🔍 ANALYSIS: Sources of Sudden Color/Brightness Changes

## 🚨 **IDENTIFIED PROBLEMS:**

### 1. **CONFLICTING EASING TYPES** ⚠️
**Location:** `presentation_manager.gd` lines 278, 296, 428, 435
**Problem:** 
```gdscript
# Main transition uses CUBIC
transition_tween.set_trans(Tween.TRANS_CUBIC)  # Line 278

# But colors use SINE
.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)  # Lines 296, 428
```
**Effect:** Different easing curves cause mismatched timing → sudden jumps

### 2. **EXTREME BRIGHTNESS JUMPS** ⚠️
**Location:** `presentation_manager.gd` lines 306-312, 438-443
**Problem:**
```gdscript
# Day to Night: 1.8 → 0.001 (1800x decrease!)
directional_light.light_energy = e,
original_energy,    # 1.8 (very bright)
0.001,             # 0.001 (almost black) 
```
**Effect:** Massive brightness change causes sudden darkness

### 3. **MOON LIGHT TIMING MISMATCH** ⚠️
**Location:** `presentation_manager.gd` lines 374-376, 474-475
**Problem:**
```gdscript
# Night transition: Moon light appears at 40% with 60% duration
.set_delay(transition_duration * 0.4)  # Too late
transition_duration * 0.6             # Too short

# Day transition: Moon light disappears in 30% duration
transition_duration * 0.3             # Too fast
```
**Effect:** Sudden light changes when moon appears/disappears

### 4. **HARD-CODED SHADER TRANSITIONS** ⚠️
**Location:** `sky.gdshader` lines 188-191, 213-216
**Problem:**
```glsl
float shooting_mask = ceil(...)  // Hard step function
float astro_mask = ceil(...)     // Hard step function
```
**Effect:** Stars/celestial objects appear/disappear suddenly

### 5. **STEP FUNCTIONS IN CLOUDS** ⚠️
**Location:** `sky.gdshader` lines 119-122
**Problem:**
```glsl
float density = smoothstep(
    base_density - clouds_smoothness * 0.5,    // Small range
    base_density + clouds_smoothness * 1.5,    // Can cause sudden steps
    combined_noise
);
```
**Effect:** Cloud density can jump suddenly

## 🎯 **FIXES NEEDED:**

1. **Unify Easing:** Use same transition type for all elements
2. **Gradual Brightness:** Reduce light energy range (1.8 → 0.2 instead of 0.001)
3. **Synchronized Moon Light:** Match timing with celestial objects
4. **Smooth Shader Steps:** Replace `ceil()` with `smoothstep()`
5. **Gentle Cloud Transitions:** Increase smoothness range
