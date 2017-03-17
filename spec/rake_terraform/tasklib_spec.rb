require 'spec_helper'

describe RakeTerraform::TaskLib do
  it 'adds an attribute reader and writer for each parameter specified' do
    class TestTask < RakeTerraform::TaskLib
      parameter :spinach
      parameter :lettuce
    end

    test_task = TestTask.new
    test_task.spinach = 'healthy'
    test_task.lettuce = 'dull'

    expect(test_task.spinach).to eq('healthy')
    expect(test_task.lettuce).to eq('dull')
  end

  it 'defaults the parameters to the provided defaults when not specified' do
    class TestTask < RakeTerraform::TaskLib
      parameter :spinach, default: 'green'
      parameter :lettuce, default: 'crisp'
    end

    test_task = TestTask.new

    expect(test_task.spinach).to eq('green')
    expect(test_task.lettuce).to eq('crisp')
  end

  it 'throws RequiredParameterUnset exception on initialisation if required parameters are nil' do
    class TestTask < RakeTerraform::TaskLib
      parameter :spinach, required: true
      parameter :lettuce, required: true
    end

    expect {
      TestTask.new
    }.to raise_error { |error|
      expect(error).to be_a(RakeTerraform::RequiredParameterUnset)
      expect(error.message).to match('spinach')
      expect(error.message).to match('lettuce')
    }
  end

  it 'allows the provided block to configure the task' do
    class TestTask < RakeTerraform::TaskLib
      parameter :spinach
      parameter :lettuce

    end

    test_task = TestTask.new do |t|
      t.spinach = 'healthy'
      t.lettuce = 'green'
    end

    expect(test_task.spinach).to eq('healthy')
    expect(test_task.lettuce).to eq('green')
  end
end
