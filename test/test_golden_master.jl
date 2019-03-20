function run_thermal_bubble_golden_master_tests()
    Nx, Ny, Nz = 16, 16, 16
    Lx, Ly, Lz = 100, 100, 100
    Δt = 6

    model = Model(N=(Nx, Ny, Nz), L=(Lx, Ly, Lz), ν=4e-2, κ=4e-2)

    # Add a cube-shaped warm temperature anomaly that takes up the middle 50%
    # of the domain volume.
    i1, i2 = round(Int, Nx/4), round(Int, 3Nx/4)
    j1, j2 = round(Int, Ny/4), round(Int, 3Ny/4)
    k1, k2 = round(Int, Nz/4), round(Int, 3Nz/4)
    model.tracers.T.data[i1:i2, j1:j2, k1:k2] .+= 0.01

    # Uncomment to include a checkpointer that produces the golden master.
    # checkpointer = Checkpointer(dir=".",
    #                             prefix="thermal_bubble_golden_master_",
    #                             frequency=10, padding=2)
    # push!(model.output_writers, checkpointer)

    time_step!(model, 10, Δt)

    golden_master_fp = "thermal_bubble_golden_master_model_checkpoint_10.jld"
    golden_master = restore_from_checkpoint(golden_master_fp)

    # Now test that the model output matches the golden master.
    @test all(model.velocities.u.data .≈ golden_master.velocities.u.data)
    @test all(model.velocities.v.data .≈ golden_master.velocities.v.data)
    @test all(model.velocities.w.data .≈ golden_master.velocities.w.data)
    @test all(model.tracers.T.data    .≈ golden_master.tracers.T.data)
    @test all(model.tracers.S.data    .≈ golden_master.tracers.S.data)
    @test all(model.G.Gu.data         .≈ golden_master.G.Gu.data)
    @test all(model.G.Gv.data         .≈ golden_master.G.Gv.data)
    @test all(model.G.Gw.data         .≈ golden_master.G.Gw.data)
    @test all(model.G.GT.data         .≈ golden_master.G.GT.data)
    @test all(model.G.GS.data         .≈ golden_master.G.GS.data)
end
