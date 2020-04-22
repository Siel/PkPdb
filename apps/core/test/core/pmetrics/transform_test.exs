defmodule Core.Dataset.Pmetrics.TransformTest do
  use Core.DataCase
  alias Core.Dataset.Pmetrics.Transform
  alias Core.Dataset

  describe "transform" do
    test " set_to/2 nonmem, does nothing if the ids are numeric" do
      data =
        "POPDATA DEC_11,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\n#ID,EVID,TIME,DUR,DOSE,ADDL,II,INPUT,OUT,OUTEQ,C0,C1,C2,C3\n1,1,0,6,151650.2294,.,.,1,.,.,.,.,.,.\n1,0,3,.,.,.,.,.,114.5,1,.,.,.,."

      ds = Core.DatasetsFixtures.dataset_fixture(data, "pmetrics")

      {:ok, dataset} = Dataset.get(ds.dataset.id)
      transform = Transform.set_to(dataset, "nonmem")
      assert(dataset.events == transform.events)
    end

    test "set_to/2 nonmem, creates a new autoincremental id if the ids are not numeric" do
      data =
        "POPDATA DEC_11,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\n#ID,EVID,TIME,DUR,DOSE,ADDL,II,INPUT,OUT,OUTEQ,C0,C1,C2,C3\na,1,0,6,151650.2294,.,.,1,.,.,.,.,.,.\nb,0,3,.,.,.,.,.,114.5,1,.,.,.,."

      ds = Core.DatasetsFixtures.dataset_fixture(data, "pmetrics")

      {:ok, dataset} = Dataset.get(ds.dataset.id)
      transform = Transform.set_to(dataset, "nonmem")
      assert(dataset.events != transform.events)
      [ev1, ev2] = transform.events
      assert(ev1.subject == 0)
      assert(ev2.subject == 1)
    end
  end
end
