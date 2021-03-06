mutable struct TimeStepWizard{T}
              cfl :: T
    diffusive_cfl :: T
       max_change :: T
       min_change :: T
           max_Δt :: T
               Δt :: T
end

"""
    TimeStepWizard(cfl=0.1, max_change=2.0, min_change=0.5, max_Δt=Inf)

A type for calculating adaptive time steps based on capping the CFL number at `cfl`.

On calling `update_Δt!(wizard, model)`, the `TimeStepWizard` computes a time-step such that
``cfl = max(u/Δx, v/Δy, w/Δz) Δt``, where ``max(u/Δx, v/Δy, w/Δz)`` is the maximum ratio
between model velocity and along-velocity grid spacing anywhere on the model grid. The new
`Δt` is constrained to change by a multiplicative factor no more than `max_change` or no
less than `min_change` from the previous `Δt`, and to be no greater in absolute magnitude
than `max_Δt`.
"""
TimeStepWizard(; cfl=0.1, diffusive_cfl=Inf, max_change=2.0, min_change=0.5, max_Δt=Inf, Δt=0.01) =
        TimeStepWizard(cfl, diffusive_cfl, max_change, min_change, max_Δt, Δt)

"""
    update_Δt!(wizard, model)

Compute `wizard.Δt` given the velocities and diffusivities of `model`, and the parameters
of `wizard`.
"""
function update_Δt!(wizard, model)

    Δt = min(
             wizard.cfl * cell_advection_timescale(model),          # advective
             wizard.diffusive_cfl * cell_diffusion_timescale(model) # diffusive
            )

    # Put the kibosh on if needed
    Δt = min(wizard.max_change * wizard.Δt, Δt)
    Δt = max(wizard.min_change * wizard.Δt, Δt)
    Δt = min(wizard.max_Δt, Δt)

    wizard.Δt = Δt

    return nothing
end

(c::CFL{<:TimeStepWizard})(model) = c.Δt.Δt / c.timescale(model)
